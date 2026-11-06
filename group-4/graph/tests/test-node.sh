#!/bin/sh
# Tests graph/node.sh without calling a model. Each case runs in its own throwaway group.
set -u

here=$(cd "$(dirname "$0")/.." && pwd)
root="$here/runs/test-node"
group="$root/group"
failed=0

ok() {
  printf '  ok   %s\n' "$1"
}

fail() {
  printf '  FAIL %s\n' "$1"
  failed=1
}

check() {
  name=$1
  shift
  if "$@"; then ok "$name"; else fail "$name"; fi
}

contains() {
  grep -F "$2" "$1" > /dev/null 2>&1
}

status_is() {
  contains "$1/output.json" "\"status\":\"$2\""
}

valid_output() {
  (
    . "$group/graph/lib.sh"
    json_valid "$1/output.json"
  )
}

node_exited() {
  [ "$node_code" -eq "$1" ]
}

green_result() {
  node_exited 0 && status_is "$1" green && valid_output "$1"
}

red_result() {
  node_exited 1 && status_is "$1" red && valid_output "$1"
}

why_has() {
  contains "$1/output.json" "$2"
}

fresh_group() {
  rm -rf "$root"
  mkdir -p "$group/app" "$group/tickets" "$group/graph/tests" "$group/graph/runs/cases"
  cp "$here/node.sh" "$group/graph/node.sh"
  cp "$here/lib.sh" "$group/graph/lib.sh"
  cp "$here/REPORT.md" "$group/graph/REPORT.md"
  cp "$here/tests/fake-agent.sh" "$group/graph/tests/fake-agent.sh"
}

run_node() {
  step=$1
  mkdir -p "$root/logs"
  log_name=$(printf '%s' "$step" | tr '/' '-')
  (cd "$group" && sh graph/node.sh "$step") > "$root/logs/$log_name.log" 2>&1
  node_code=$?
}

write_job() {
  step=$1
  job=$2
  mkdir -p "$group/$step"
  printf '%s\n' "$job" > "$group/$step/input.json"
}

has_only_node_answers() {
  step=$1
  expected='input.json
output.json
report.md'
  actual=$(find "$group/$step" -maxdepth 1 -type f -exec basename {} \; | sort)
  [ "$actual" = "$expected" ]
}

has_extra_artifact() {
  ! has_only_node_answers "$1"
}

fresh_group

step=graph/runs/cases/commands-pass
write_job "$step" '{"kind":"commands","dir":"app","run":"printf command-output"}'
run_node "$step"
check "commands that pass exit green with valid JSON" green_result "$group/$step"
check "commands that pass write their output to report.md" contains "$group/$step/report.md" command-output

step=graph/runs/cases/commands-fail
write_job "$step" '{"kind":"commands","dir":"app","run":"printf failure-diagnostic >&2; exit 7"}'
run_node "$step"
check "commands that fail exit red with valid JSON" red_result "$group/$step"
check "commands that fail name report.md in why" why_has "$group/$step" report.md
check "commands that fail retain their diagnostic in report.md" contains "$group/$step/report.md" failure-diagnostic

step=graph/runs/cases/agent-good
: > "$group/tickets/good.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/good.md","agent":"graph/tests/fake-agent.sh"}'
run_node "$step"
check "an agent with a complete report exits green with valid JSON" green_result "$group/$step"
check "an agent log is kept in the step folder" test -f "$group/$step/agent.log"

step=graph/runs/cases/agent-no-report
: > "$group/tickets/no-report.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/no-report.md","agent":"graph/tests/fake-agent.sh"}'
run_node "$step"
check "an agent without a report exits red with valid JSON" red_result "$group/$step"
check "a missing report says why" why_has "$group/$step" "agent left no report"

step=graph/runs/cases/agent-bad-report
: > "$group/tickets/bad-report.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/bad-report.md","agent":"graph/tests/fake-agent.sh"}'
run_node "$step"
check "an agent report missing a heading exits red with valid JSON" red_result "$group/$step"
check "a missing heading says which heading is absent" why_has "$group/$step" "## Checked"

step=graph/runs/cases/agent-fail
: > "$group/tickets/fail.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/fail.md","agent":"graph/tests/fake-agent.sh"}'
run_node "$step"
check "a failing agent exits red with valid JSON" red_result "$group/$step"
check "a failing agent says why" why_has "$group/$step" "agent failed"

step=graph/runs/cases/agent-slow
: > "$group/tickets/slow.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/slow.md","agent":"graph/tests/fake-agent.sh","limit":2}'
run_node "$step"
check "an agent cut at its limit exits red with valid JSON" red_result "$group/$step"
check "a timed-out agent says why" why_has "$group/$step" "agent cut after 2 s"

step=graph/runs/cases/agent-outside
: > "$group/tickets/outside.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/outside.md","agent":"graph/tests/fake-agent.sh"}'
run_node "$step"
check "an agent writing outside app exits red with valid JSON" red_result "$group/$step"
check "an outside write names its path" why_has "$group/$step" tickets/outside.txt

step=graph/runs/cases/reviewer-block
: > "$group/tickets/block.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/block.md","agent":"graph/tests/fake-agent.sh"}'
run_node "$step"
check "a blocking reviewer verdict exits red with valid JSON" red_result "$group/$step"
check "a blocking reviewer verdict gives its reason" why_has "$group/$step" "The ticket asks for a test"

step=graph/runs/cases/reviewer-pass
: > "$group/tickets/pass.md"
write_job "$step" '{"kind":"agent","dir":"app","ticket":"tickets/pass.md","agent":"graph/tests/fake-agent.sh"}'
run_node "$step"
check "a passing reviewer verdict exits green with valid JSON" green_result "$group/$step"

malformed_count=0
for malformed in \
  '{"kind":"commands","kind":"agent","dir":"app","run":"printf should-not-run"}' \
  '{"kind":"agent","dir":"app","ticket":"tickets/a.md","ticket":"tickets/b.md","ticket":"tickets/c.md","agent":"graph/tests/fake-agent.sh"}' \
  '{"kind":"commands","run":"printf should-not-run"}' \
  '{"kind":"unknown","dir":"app","run":"printf should-not-run"}'
do
  step=graph/runs/cases/malformed-$((malformed_count=${malformed_count:-0}+1))
  write_job "$step" "$malformed"
  run_node "$step"
  check "a malformed job exits red with valid JSON ($malformed_count)" red_result "$group/$step"
  check "a malformed job writes only node answers ($malformed_count)" has_only_node_answers "$step"
done

step=graph/runs/cases/file-list-check
write_job "$step" '{"kind":"commands","dir":"app","run":"printf should-not-run"}'
: > "$group/$step/output.json"
: > "$group/$step/report.md"
: > "$group/$step/extra.txt"
check "the malformed-artifact assertion rejects an extra file" has_extra_artifact "$step"

exit "$failed"
