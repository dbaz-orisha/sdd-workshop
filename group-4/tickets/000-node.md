# 000 · The node

Signed: group-4, approved in this session on 2026-11-06.

## GOAL

One program, `graph/node.sh`, runs any step of the graph from a job written in a folder:
commands (grey) or an agent with a ticket (blue). It always answers green or red with the
reason, so nobody has to read a log to know what happened.

## SCOPE

May write: `graph/node.sh` and `graph/tests/test-node.sh`.
May not write: `graph/lib.sh`, `graph/copilot.sh`, `graph/tests/fake-agent.sh`,
`graph/REPORT.md`, `graph/NODE.md`, `app/`, `tickets/`, `openspec/`.

## CONTEXT

The contract is `graph/NODE.md`, and the OpenSpec change `openspec/changes/generic-node/`.
The first worker built the node and a test with 27 passing assertions. Follow-up
verification found two existing-contract failures: a failed command's output is
overwritten by the node's generic error, and the test's `has_only_node_answers`
uses a multiline grep pattern that accepts any matching file name instead of
comparing the whole file list. It even passes a list containing `extra.txt`.
The failed-command reproduction is
`graph/runs/verify-command-failure/input.json`; its diagnostic must remain in
`report.md`. Fix these gaps with regression tests first, then node changes.
Given and ready: `graph/lib.sh` (`json_get`, `json_valid`,
`json_escape`, `run_limited`), `graph/tests/fake-agent.sh` (the agent of the tests) and
`graph/REPORT.md` (the four headings of an agent's report).

Approved guardrails: agent jobs in this exercise use `dir: "app"`; changes outside
that directory and `graph/runs/` are red. The default limit is 300 seconds when
the job omits `limit`; the timeout test supplies `limit: 2` in its own
`input.json`. Missing reports or any missing required heading are red.
Use the contract's git-prefix handling so legitimate `group-4/app/` paths pass.

## ACCEPTANCE

1. Commands that pass: green, exit 0, and `report.md` has their output.
2. Commands that fail: red, exit 1, and the why names `report.md`; the report retains the command's stdout and stderr, including its diagnostic before failure.
3. The agent finishes with a four-heading report: green, with `agent.log` in the step folder; no report or a missing required heading is red with the reason.
4. The agent fails, or runs past its `limit` (`"limit":2`, ticket `slow.md`): red, and the why says which.
5. The agent writes outside `dir`: red, and the why names the path.
6. A malformed job (two `kind`, three `ticket`, no `dir`, an unknown `kind`): red, nothing run, nothing written but `output.json` and `report.md`; compare the complete file list, excluding the preexisting input, and reject any extra artifact.
7. `Verdict: block` in the report is red; `Verdict: pass` is green.

## VERIFY

`sh graph/tests/test-node.sh`: one `  ok` line per check, no `  FAIL`, exit 0. It builds a
throwaway group folder and uses `graph/tests/fake-agent.sh`: no model is called.

Keep throwaway fixtures and execution artifacts under `graph/runs/`, not `/tmp`.
The worker launcher writes only this test in its first job and proves it red
before implementation. Its second job fixes the node without changing the test.

For this follow-up, the first job strengthens the test against the current node,
not a stub: assert exact exit codes and valid JSON output, retained failed-command
diagnostics, and exact malformed-job artifacts. Keep the test harness's capture
log outside each tested step folder. Add a test of the file-list assertion itself
showing it rejects an extra file. Preserve all existing contract coverage and use
portable POSIX shell tools rather than GNU-only `find -printf`.
The first job must be red because diagnostics are lost; the second job fixes
the node until the strengthened test passes unchanged.

## FORBIDDEN

Calling a real model from the test. Editing `fake-agent.sh` or `lib.sh` to make a case
pass. A node file per step, or a second program for agents: one node.

## REPORT

Done or blocked, the files you changed, and the full output of `sh graph/tests/test-node.sh`.
