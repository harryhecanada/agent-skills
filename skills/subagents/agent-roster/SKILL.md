---
name: agent-roster
description: "Use when delegating to a named subagent role (plan, logic, build, surgical, design, scribe, tester, advisor, hunter, sentinel, ship). Loads the role's brief, the delegate_task call shape, and its output schema."
version: 1.0.0
author: Harry + Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [delegation, subagents, agents, roles, review, workflow]
    related_skills: [subagent-driven-development, writing-plans, requesting-code-review, systematic-debugging]
---

# Agent Roster — 11 Roles Dispatched Through `delegate_task`

The eleven agents are **roles**, not processes and not profiles. Each one is realised as a
`delegate_task` child: a fresh conversation that knows nothing about yours, receives only the
`goal` you write and the `context` you hand it, and returns a summary.

There is no `agent=` parameter on `delegate_task`. The role is carried by the brief the child
loads, which is the first thing in its `context`:

```
Act as the `{role}` agent. Load your role brief first:
    skill_view(name='agent-roster', file_path='references/{role}.md')
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
- **`goal` + `context` + this brief.** Nothing else. Its system prompt is "You are a focused
  subagent...", your context block, the workspace path, and the project's context files
  (`AGENTS.md`/`CLAUDE.md`) if a workspace is set. **`SOUL.md is deliberately excluded`** —
  the parent owns identity.
- **Your toolsets, minus a fixed block list**: `delegate_task`, `clarify`, `memory`,
  `send_message`, `cronjob_manage`. So it can read/write files and run commands but cannot
  ask you a question, cannot delegate further, and cannot write memory.
- **No recursive delegation.** `delegation.max_spawn_depth` defaults to 1. If you need a child
  that spawns children, raise it in config — the roster does not rely on it.
- **`skill_view` is available**, which is why the child loads its own brief instead of you
  pasting it. If a child ever reports the brief unavailable, paste the reference text into
  `context` instead.

## Call Shapes

Single role:

```
delegate_task(tasks=[{
  "goal": "Fix the login redirect loop",
  "context": "Act as the `surgical` agent. Load your role brief: skill_view(name='agent-roster', file_path='references/surgical.md') and follow it exactly.\n\nREPRO: <cmd> -> <observed output>\nEXPECTED: <...>\nFILES IN SCOPE: <...>\nTEST COMMAND: <...>",
}])
```

Parallel roles — fan out by area, never by size, and never two children on one file:

```
delegate_task(tasks=[
  {"goal": "Sweep src/auth for bug classes", "context": "Act as the `hunter` agent. Load skill_view(name='agent-roster', file_path='references/hunter.md'). SCOPE: src/auth ..."},
  {"goal": "Sweep src/upload for bug classes", "context": "Act as the `hunter` agent. Load ... SCOPE: src/upload ..."},
])
```

With a machine-checkable return, pass `output_schema` (the exact schema per role is in its
brief and in the table below) so you are not parsing prose:

```
delegate_task(tasks=[{"goal": "...", "context": "...", "output_schema": {...}}])
```

Review dispatch — the one everyone gets wrong: the reviewer must **not** share the author's
context, or it inherits the author's assumptions:

```
delegate_task(tasks=[{
  "goal": "Review the diff at <path or git range> against the spec in <spec>",
  "context": "Act as the `advisor` agent. Load skill_view(name='agent-roster', file_path='references/advisor.md').\nSPEC: <verbatim>\nDIFF: <git diff command or file list>\nCONVENTIONS: <style/test norms>\nAUTHOR'S EVIDENCE: <what build claimed>",
}])
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
name, and stop when a command is refused. This is the default in Hermes — subagent worker threads
get a non-interactive approval callback that **auto-denies** dangerous commands
(`delegation.subagent_auto_approve` defaults to `false`), so a sandbox child that tries something
dangerous is refused and should report that refusal rather than route around it.

`auto` (`build`, `tester`) means the child is expected to run the real test/lint/build and may
need to move files around to do it. If those dispatches keep coming back with refusals, that is
the signal to set `delegation.subagent_auto_approve: true` — it is a **global** setting, not a
per-role one, so enable it deliberately and only when the sandbox refusals are actually blocking
implementation work.

Mode is advisory where Hermes cannot enforce it: `advisor` and `hunter` are `subagent-only` by
convention, so do not hand a session to them — dispatch them and take the report back.

## Coordinating The Team

The parent session is the only coordinator: children cannot delegate (the `delegate_task` tool is
stripped from every child, `delegation.max_spawn_depth` defaults to 1), cannot ask the user, cannot
write memory, and cannot message anyone. Every handoff goes through the parent, by artifact, not by
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

- **Do not pass `toolsets`.** There is no model-facing toolsets argument; children inherit yours. Older
  examples that show `toolsets=['file']` are misleading.
- **A child cannot ask you anything.** Anything ambiguous must be resolved before dispatch, or the
  child returns a blocked result with a reason. That return is a success, not a failure.
- **Children cannot delegate.** If work needs sub-fanning, either raise `delegation.max_spawn_depth`
  or keep the fan-out in the parent.
- **Results are self-reports.** A child claiming it wrote a file, ran a suite, or passed a gate has
  not been verified by you. Check the artifact before repeating the claim (`VERIFY SIDE EFFECTS`).
- **Never let the author review itself.** `build` reviewing `build` is not a review; dispatch
  `advisor` fresh.
- **Source of truth for the roster** is this skill. `SOUL.md` carries a short pointer to it, not a
  second copy — update the roster here.

## Further Reading

- `references/<role>.md` — the eleven role briefs (this is what children load).
