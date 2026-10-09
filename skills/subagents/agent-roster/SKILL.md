---
name: agent-roster
description: "Use when delegating to a named subagent role (plan, logic, build, surgical, design, scribe, tester, advisor, hunter, sentinel, ship). Loads the role's brief, the dispatch shape, and its output schema."
version: 1.2.0
author: Harry
license: MIT
platforms: [linux, macos, windows]
---

# Agent Roster — 11 Roles Dispatched Through `delegate`

The eleven agents are **roles**, not processes and not profiles. Each one is realised as a
`delegate` child: a fresh conversation that knows nothing about yours, receives only the
`goal` you write and the `context` you hand it, and returns a summary.

There is no `agent=` parameter to set. The role is carried by the brief the child loads, and it
comes first:

```
Act as the `{role}` agent. Load your role brief first: read
    <this skill>/references/{role}.md
Follow it exactly. Then: <the task>
```

That single line is the whole mechanism. Everything else below is how to use it well.

## The Roster

- `plan` — read-only architect; design tree, then a written plan for approval. sandbox / main+sub
- `logic` — invariants, decision tables, state machines, exhaustive coverage. sandbox / main+sub
- `build` — TDD implementer, vertical slices at agreed seams. auto / main+sub
- `surgical` — minimal-diff bug fixes, root cause first, no surrounding refactors. sandbox / main+sub
- `design` — UI/UX and design systems, states, a11y, light/dark parity. sandbox / main+sub
- `scribe` — keeps docs true and in sync with code and config. sandbox / main+sub
- `tester` — closes coverage gaps via TDD at public seams. auto / main+sub
- `advisor` — two-axis review (Standards + Spec), P1/P2/P3 with `file:line` and a fix. sandbox / subagent-only
- `hunter` — whole-codebase sweep: bug classes, dead code, quality risks. sandbox / subagent-only
- `sentinel` — threat-model-first security audit, exploit paths, no fixes. sandbox / main+sub
- `ship` — release verdict SHIP/NO-SHIP with an evidence-backed gate table. sandbox / main+sub

## What A Child Actually Gets

Know this before you write a dispatch, because it decides what you must put in `context`:

- **No conversation history.** It has never seen this session.
- **Your brief and nothing else.** Its system prompt is minimal, it receives the brief you write,
  and it may also see the workspace path and the project's context files (`AGENTS.md`/
  `CLAUDE.md`) when a workspace is set. **The agent's identity file is deliberately excluded** —
  the parent owns identity.
- **A subset of your tools.** Most agents strip delegation, user questions, messaging and memory
  writes from a child. So it can read/write files and run commands, but it cannot ask you a
  question, cannot delegate further, and cannot write memory.
- **No recursive delegation.** Assume a child cannot spawn children; keep the fan-out in the
  parent. The roster never relies on nesting.
- **It can read files**, which is why the child loads its own brief instead of you pasting it.
  If a child reports the brief unreachable, paste the reference text into the brief instead.

## Call Shapes

Single role:

```
delegate(brief: """
Act as the `surgical` agent. Load your role brief first:
    <this skill>/references/surgical.md
Follow it exactly.

GOAL: Fix the login redirect loop
REPRO: <cmd> -> <observed output>
EXPECTED: <...>
FILES IN SCOPE: <...>
TEST COMMAND: <...>
RETURN: the diff, the test command and its output, and anything unverified.
""")
```

Parallel roles — fan out by area, never by size, and never two children on one file:

```
delegate(brief: """Act as the `hunter` agent. Load <this skill>/references/hunter.md, follow it exactly.
SCOPE: src/auth ...""")
delegate(brief: """Act as the `hunter` agent. Load <this skill>/references/hunter.md, follow it exactly.
SCOPE: src/upload ...""")
```

Dispatch every child in one turn, then end the turn: a child returns exactly one result, and on
most platforms it cannot message you mid-run.

Where the tool takes a machine-checkable return, pass the role's output schema (the exact schema
per role is in its brief and in the table below) so you are not parsing prose.

Review dispatch — the one everyone gets wrong: the reviewer must **not** share the author's
context, or it inherits the author's assumptions:

```
delegate(brief: """
Act as the `advisor` agent. Load your role brief first:
    <this skill>/references/advisor.md
Follow it exactly.

GOAL: Review the diff at <path or git range> against the spec in <spec>
SPEC: <verbatim>
DIFF: <git diff command or file list>
CONVENTIONS: <style/test norms>
AUTHOR'S EVIDENCE: <what build claimed>
""")
```

## Output Schemas

Role briefs carry a JSON Schema; the ones worth using every time:

- `advisor` → `verdict` (approve | changes_requested) + `findings[]` with `axis`, `severity` (P1/P2/P3), `location`, `issue`, `fix`.
- `hunter` → `findings[]` with `severity`, `location`, `bug_class`, `issue`, `proof`.
- `sentinel` → `threat_model` + `findings[]` with `severity`, `location`, `exploit_path`, `trigger_input`, `impact`.
- `ship` → `verdict` (SHIP | NO-SHIP) + `revision` + `gates[]` with `name`, `status`, `evidence`.
- `build` / `tester` / `surgical` → `files_changed`/`tests_added`, `status`, and `unverified[]` (the gap round).

Keep the schema forgiving — require only the fields you will actually read; the child's raw text
comes back either way.

## Policy: sandbox and auto

`sandbox` (9 of 11 roles) means **read-and-report**: modify nothing the task did not explicitly
name, and stop when a command is refused. Where your platform gives children a non-interactive
approval path that auto-denies dangerous commands, a sandbox child that tries something dangerous
is refused — it should report that refusal rather than route around it.

`auto` (`build`, `tester`) means the child is expected to run the real test/lint/build and may
need to move files around to do it. If those dispatches keep coming back with refusals, that is
the signal to loosen that policy — and because such a setting is usually **global** rather than
per-role, loosen it deliberately and only when the refusals are actually blocking implementation
work.

Mode is advisory where the platform cannot enforce it: `advisor` and `hunter` are `subagent-only`
by convention, so do not hand a session to them — dispatch them and take the report back.

## Coordinating The Team

The parent session is the only coordinator: children cannot delegate (the delegation tool is
withheld from them), cannot ask the user, cannot write memory, and cannot message anyone. Every handoff goes through the parent, by artifact, not by
re-explanation.

**Pipeline**

1. `plan` — for non-trivial work, get the plan and the human's approval before anything is built.
2. `logic` — when correctness is the risk, pin the invariants and the decision table first.
3. `build` — one vertical slice per child, dispatched sequentially when slices touch the same files.
4. `tester` — pin the behaviour that build just changed; dispatch fresh from the seam.
5. `advisor` — two-axis review of the actual diff. Dispatch fresh, never reuse the author's context.
6. `surgical` — defects with a reproduction; `hunter` for the sweep an advisor would never see in a diff.
7. `sentinel` — before shipping anything that takes untrusted input or handles credentials.
8. `scribe` — after any behaviour change, make the docs true again.
9. `ship` — SHIP/NO-SHIP on the revision, with the earlier agents' raw reports in hand.

`hunter` and `sentinel` can run at any point. `advisor` and `hunter` are subagent-only by design —
never drive a session with them.

**Handoff contract** — every dispatch's `context` names the input artifact (path or diff), the
output artifact expected, and what "done" means for that slice. Every result is a self-report: when
a child says it wrote a file or ran a suite, verify the side effect yourself before acting on it.

**Parallelism** — parallel children must not touch the same files. Fan out by directory, module, or
surface, not by task size. When two children would edit one file, dispatch them one after the other.

**Order matters** — spec compliance before quality review; review before release; docs after
behaviour freezes. A `ship` verdict that arrives before `sentinel` has reported is not a verdict.

## Pitfalls

- **Do not pass a tool list.** Children inherit your tools; there is no model-facing toolsets
  argument. Examples that show `toolsets=['file']` are misleading.
- **A child cannot ask you anything.** Anything ambiguous must be resolved before dispatch, or the
  child returns a blocked result with a reason. That return is a success, not a failure.
- **Children cannot delegate.** Keep the fan-out in the parent; nothing in the roster relies on a
  child spawning grandchildren.
- **Results are self-reports.** A child claiming it wrote a file, ran a suite, or passed a gate has
  not been verified by you. Check the artifact before repeating the claim (`VERIFY SIDE EFFECTS`).
- **Never let the author review itself.** `build` reviewing `build` is not a review; dispatch
  `advisor` fresh.
- **Source of truth for the roster** is this skill. Your agent's identity file carries a short
  pointer to it, not a second copy — update the roster here.

## Further Reading

- `references/<role>.md` — the eleven role briefs (this is what children load).
