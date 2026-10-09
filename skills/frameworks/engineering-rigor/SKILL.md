---
name: engineering-rigor
description: Rigorous agentic engineering workflow — 23 playbooks and 23 principle rules for bug fixes, features, refactors, performance work, investigations, architecture decisions, code review, and long autonomous runs. Use for any non-trivial engineering task, or when the user asks for rigor, anti-slop discipline, verified work, or a plan they can audit. Also use when work must be proven against real runtime evidence rather than declared done.
version: 1.0.0
---

# Engineering rigor

A workflow skill set for agents doing real engineering work: match the task to a playbook, work
under explicit principles, delegate in isolated contexts, and prove the result against the real
artifact before claiming it works. It is a port of Lauren Tan's (poteto) pstack workflows, via
Joel Taroreh's agentic engineering framework.

Works on any agent that can run commands and spawn subagents. Nothing here names a product: skills
refer to **capabilities** (`shell`, `delegate`, `browser`, …) that you map onto whatever tools you
actually have. Read [`TOOLS.md`](TOOLS.md) first — it is the contract that makes the rest portable.

```
engineering-rigor/
├── SKILL.md            this file
├── TOOLS.md            capability vocabulary and how to map it to your tools
├── README.md           what this is, how to use it, provenance
├── rules/
│   ├── AGENTS.md       delegation, fan-out and verification invariants
│   └── models.md       per-role model classes
├── agents/             brief templates for the subagents you dispatch
├── scripts/            command gates (run them as CLIs)
├── skills/
│   ├── poteto-mode/    the engine: SKILL.md + 23 playbooks + references
│   ├── principle-*/    the 23 principle rules
│   └── <leaf skills>   how, why, recall, architect, arena, swarm, interrogate, deslop,
│                       no-comments, unslop, technical-writing, tdd, teach, reflect,
│                       blast-radius, figure-it-out, automate-me, loop, show-me-your-work,
│                       create-verification-skill, maintain-verification-skill,
│                       typescript-best-practices, bro
└── tests/              the skill set's own suite (catalog, hooks, invariants)
```

Paths in this skill set are relative to this directory unless stated otherwise.

## The contract

1. **Read [`TOOLS.md`](TOOLS.md), then [`skills/poteto-mode/SKILL.md`](skills/poteto-mode/SKILL.md)
   in full** — including its inline Principles index. That file is the engine; this one is the entry.
   Its **Non-negotiables** list is the trigger table.
2. **Open a todo list**, first item `read the Principles section`. Match the task to one of the 23
   playbooks in `skills/poteto-mode/playbooks/` and copy the matched playbook's steps in verbatim.
   A step you choose not to run stays in the list as `skip: <reason>`.
3. **Apply the principle you cite.** Name the principles that shaped a decision and the specific
   choice each one changed. A citation with no decision behind it means you skipped the leaf skill —
   read `skills/<principle-name>/SKILL.md` before claiming it.
4. **This is a mode, not a one-shot.** Once entered it stays on for the task across turns, applying
   itself when a playbook matches and staying out of the way otherwise. The user opts out by saying so.
5. **Write the reply per `unslop`** (`skills/unslop/SKILL.md`) and, for anything the user must act
   on, as a deliverable file under `artifacts/<task-slug>/` that you link in the reply.

## Non-negotiables

- **Delegation invariant.** Non-trivial code edits (>50 lines on one file, or multi-file) go to a
  subagent via `delegate`, which owns the diff in an isolated context. The coordinator plans, reads
  the diff, runs verification, and talks to the user — it does not write the bulk edit itself.
  Trivial edits (≤50 lines, new files, flags, ignore files, markdown, scratch scripts) are the
  coordinator's. Children usually cannot nest, so a child owns its diff directly. Gate it with
  `scripts/gate-delegation.sh <path> [content-file]`.
- **Dispatch, then end the turn.** If your `delegate` returns immediately, end the turn and let
  results arrive; never poll in a loop to wait. `rules/AGENTS.md` has the full protocol, including
  the watchdog.
- **Fan out for real.** Review, bakeoffs, and sweeps require actual concurrent subagents on
  different model classes. Simulating reviewer personas in the parent context is forbidden — it is
  the exact failure mode this skill set exists to prevent.
- **Prove it works.** Verify against the real artifact — run the feature, read the actual value,
  inspect the rendered page, read the diff — not against a proxy, a self-report, or "it compiles."
  See `skills/principle-prove-it-works/SKILL.md`.
- **Gate destructive commands** with `scripts/gate-safety.sh "<command>"` before running them
  unattended — it catches recursive root deletion, force-push to trunk, and `drop database`.
- **Long or unattended work leaves a trail.** `skills/show-me-your-work/SKILL.md` writes
  `decisions.tsv` + `decision_trail.md` under `artifacts/<task-slug>/`, incrementally, so a later
  turn can resume from disk rather than from conversation memory. Use `schedule` for heartbeats.

## Verify the install

```bash
ls skills/poteto-mode/playbooks | wc -l     # 23
sh scripts/gate-safety.sh "rm -rf /"        # a force_ask decision
python3 -m pytest tests/ -q                 # the skill set's own suite
```

If a skill's steps reference a capability you do not have, say so and use the closest substitute —
do not invent tool names, and do not silently skip the step. If a skill's steps reference a path
that no longer exists, fix that skill in place rather than working around it silently.
