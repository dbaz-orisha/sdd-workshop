#!/bin/sh
# The node: one program for every step of the path. sh graph/node.sh <step-folder>
# The contract is graph/NODE.md. Hour 2 writes it, with its test graph/tests/test-node.sh.
set -u

root=$(pwd)
. "$root/graph/lib.sh"

step=${1:-}
job=$step/input.json
report=$step/report.md
output=$step/output.json

now() {
  date +%H:%M:%S
}

write_answer() {
  status=$1
  why=$2
  ended=$(now)
  printf '{"status":"%s","why":"%s","started":"%s","ended":"%s"}\n' \
    "$status" "$(json_escape "$why")" "$started" "$ended" > "$output"
  printf '%s: %s\n' "$status" "$why"
  [ "$status" = green ]
}

red() {
  why=$1
  printf '%s\n' "$why" > "$report"
  write_answer red "$why"
}

count_key() {
  grep -o "\"$1\"[[:space:]]*:" "$job" 2>/dev/null | wc -l | tr -d ' '
}

quote_arg() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

allowed_dir() {
  case $1 in
    ""|/*|../*|*/../*|*/..) return 1 ;;
  esac
  [ -d "$1" ]
}

started=$(now)

if [ -z "$step" ] || [ ! -f "$job" ]; then
  printf 'red: input.json is missing\n'
  exit 1
fi

kind_count=$(count_key kind)
dir_count=$(count_key dir)

if ! json_valid "$job"; then
  red "input.json is not valid JSON"
elif [ "$kind_count" -ne 1 ]; then
  red "input.json must contain kind exactly once"
elif [ "$dir_count" -ne 1 ]; then
  red "input.json must contain dir exactly once"
else
  kind=$(json_get "$job" kind)
  dir=$(json_get "$job" dir)

  if ! allowed_dir "$dir"; then
    red "dir does not exist: $dir"
  elif [ "$kind" = commands ]; then
    run_count=$(count_key run)
    if [ "$run_count" -ne 1 ]; then
      red "commands job must contain run exactly once"
    else
      run=$(json_get "$job" run)
      if sh -c "$run" > "$report" 2>&1; then
        write_answer green "commands finished, report.md written"
      else
        write_answer red "commands failed; see report.md"
      fi
    fi
  elif [ "$kind" = agent ]; then
    ticket_count=$(count_key ticket)
    if [ "$ticket_count" -ne 1 ]; then
      red "agent job must contain ticket exactly once"
    else
      ticket=$(json_get "$job" ticket)
      agent=$(json_get "$job" agent)
      limit=$(json_get "$job" limit)
      skill=$(json_get "$job" skill)
      model=$(json_get "$job" model)
      last=$(json_get "$job" last)

      [ -n "$agent" ] || agent=graph/copilot.sh
      [ -n "$limit" ] || limit=300
      case $limit in
        *[!0-9]*|"") red "agent limit must be a positive number" ;;
        *)
          git_before=$(git status --porcelain --untracked-files=all 2>/dev/null || true)
          git_prefix=$(git rev-parse --show-prefix 2>/dev/null || true)
          files_before=$(find . -type f ! -path './graph/runs/*' -print | sort)
          agent_log=$step/agent.log
          export SKILL=$skill MODEL=$model LAST=$last
          command="sh $(quote_arg "$agent") $(quote_arg "$ticket") $(quote_arg "$dir") $(quote_arg "$report")"
          run_limited "$limit" "." "$agent_log" "$command"
          agent_code=$?

          if [ "$agent_code" -eq 124 ]; then
            red "agent cut after $limit s"
          elif [ "$agent_code" -ne 0 ]; then
            red "agent failed; see agent.log"
          elif [ ! -f "$report" ]; then
            red "agent left no report"
          else
            missing_heading=
            grep '^## ' "$root/graph/REPORT.md" | while IFS= read -r heading; do
              if ! grep -Fx "$heading" "$report" > /dev/null 2>&1; then
                printf '%s\n' "$heading"
                break
              fi
            done > "$step/.missing-heading"
            missing_heading=$(cat "$step/.missing-heading")
            rm -f "$step/.missing-heading"

            if [ -n "$missing_heading" ]; then
              red "report.md lacks $missing_heading"
            else
              git_after=$(git status --porcelain --untracked-files=all 2>/dev/null || true)
              files_after=$(find . -type f ! -path './graph/runs/*' -print | sort)
              changed=$(printf '%s\n---\n%s\n' "$git_before" "$git_after" |
                awk '/^---$/ { after = 1; next } !after { seen[$0] = 1; next }
                  !seen[$0] { print substr($0, 4) }')
              new_files=$(printf '%s\n---\n%s\n' "$files_before" "$files_after" |
                awk '/^---$/ { after = 1; next } !after { seen[$0] = 1; next }
                  !seen[$0] { sub(/^\.\//, ""); print }')
              changed=$(printf '%s\n%s\n' "$changed" "$new_files" | sort -u)
              outside=
              for path in $changed; do
                path=${path#"$git_prefix"}
                case $path in
                  "$dir"/*|graph/runs/*) ;;
                  *) outside="${outside}${outside:+ }$path" ;;
                esac
              done

              if [ -n "$outside" ]; then
                red "agent touched outside $dir: $outside"
              elif grep -Fx 'Verdict: block' "$report" > /dev/null 2>&1; then
                verdict_reason=$(awk 'found { print; exit } /^Verdict: block$/ { found = 1 }' "$report")
                red "reviewer blocked: $verdict_reason"
              else
                write_answer green "agent finished, report.md written"
              fi
            fi
          fi
          ;;
      esac
    fi
  else
    red "unknown kind: $kind"
  fi
fi
