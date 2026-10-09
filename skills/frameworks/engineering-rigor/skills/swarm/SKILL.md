---
name: swarm
description: "Fan out N parallel workers, drain them, and return one consolidated report. Use for parallel coverage, partitioned sweeps, races, gauntlets, and exploration that would flood one context."
version: 1.0.0
---

# Swarm

Fan out N workers. Each covers a separate slice or races the same brief. The coordinator frames the
work, dispatches, aggregates, and returns one report. Workers do the reading so the coordinator's
context stays small — that is the point of the skill.

## Start

Open a todo list with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the deliverable (`artifacts/<task-slug>/<report>.md`).
2. Choose the shape: **partition** into slices, **race** N workers on identical briefs, or mix. For a
   race, declare the rule up front: `first pass`, `rank all`, or `best-of`.
3. Set N. N is total workers, and every worker is a real model call plus a real context budget.
4. Pick the worker model class from `swarm workers` in `rules/models.md` (default: `fast`).
5. Check your concurrency cap. Dispatch every worker in one turn regardless — extras queue — but
   size N so the queue drains in a sane time.

## Phase B: Fan out

Spawn all N workers in one `delegate` call (or one turn of calls, if your tool takes one at a time),
each with a standalone brief. Every brief carries: goal, scope, the exact slice or the identical
brief for a race, the verification command, and the expected report format —
`[STATUS: PASS]`, `[STATUS: ISSUES]`, or `[STATUS: BLOCKED]`, each with evidence.

A worker gets exactly one result and cannot ask questions mid-run, so the brief must be complete on
its own. If a worker needs a decision mid-flight, make it in the coordinator and state it in the
brief.

**Dispatch & Watchdog Protocol**

- **Turn 1 (dispatch and arm):** dispatch all workers, then arm one watchdog deadline with
  `schedule create --after 10m --prompt "Watchdog: swarm workers timed out"`.
- **Turn 2 (yield):** post a status update and **end the turn**. If `delegate` returns immediately,
  dispatching *is* the yield. Never poll in a loop to wait.
- **Arrivals:** each worker returns once, as a new message, when it finishes. Record its slice as it
  lands; end the turn with no tool calls while workers remain active.
- **Teardown:** when all workers are in, cancel the watchdog and go to Phase C. If the watchdog fires
  first, diagnose with `delegate(status)`, cancel the unresponsive ones with `delegate(cancel)` —
  their partial results still come back — and aggregate what you have, naming the dropouts.

## Phase C: Aggregate

1. Collect the terminal reports.
2. Apply the selection rule for a race: rank candidates by score delta, descending.
3. **Candidate integration:** apply the winning diff to a local worktree, verify it locally, commit
   it, and re-baseline. Evaluate the next candidate only after that. Never compose several candidate
   diffs at once without verifying each step (`principle-sequence-verifiable-units`).
4. Build a compact result table: one row per worker, one line per evidenced issue, explicit dropouts.

## Phase D: Report

One consolidated report: the table, one-line issues with evidence, gaps and dropouts, and the race
rule when one was used. Point at the artifact, keep the chat reply short (`skills/unslop/SKILL.md`).

## Invariants

1. **Workers never merge.** They return evidence, diffs, or findings; the coordinator integrates.
2. **Partition by surface, not by size.** Two workers on one file are two workers fighting.
3. **Never simulate a worker in context.** A worker that was not dispatched is not a worker — the
   whole value is that its reading never enters the coordinator's context.
4. **Count side effects as progress.** Commits, files written, commands run. A worker's own summary
   of what it did is a self-report until you check the artifact
   (`skills/principle-prove-it-works/SKILL.md`).
