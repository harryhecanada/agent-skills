# Delegation, fan-out and verification invariants

Read `../TOOLS.md` for the capability vocabulary. This file is the protocol every skill in this
bundle assumes. For any non-trivial engineering task — a bug, a feature, a refactor, an
investigation, a PR, overnight or autonomous work — read and follow `../skills/poteto-mode/SKILL.md`
before the first real step. Casual chat, a one-line answer, or an explicit opt-out skips it.

## Subagent Delegation Invariant

Enforce strict separation between coordination and code execution:

1. **Mandatory delegation for code writes.** Delegate all non-trivial code modifications, feature
   implementations, bug fixes, and refactoring to a subagent (`delegate`) in an isolated context —
   briefed per `../agents/poteto-agent.md`. The parent agent operates as coordinator: planning,
   reviewing the child's diff, running verification, and talking to the user in unslopped prose.
   Pass purely technical specs, interfaces, and test criteria so the child's context stays unburdened
   by conversational prose rules. Most agents do not let a child spawn further children, so a
   delegate in that position satisfies this invariant by owning the diff directly.
   - **Non-Trivial Delegation Threshold:**
     - **Trivial edits (coordinator writes directly):** <= 50 lines on a single file (existing or
       new), single flag or constant adjustments, ignore-file entries, markdown documentation,
       scratch scripts.
     - **Non-trivial edits (must be delegated):** > 50 lines on a single file, multi-file code
       modifications, core business-logic changes.
     - **User override:** an explicit "do this directly" / "no subagents" permits coordinator writes.
2. **Mandatory fan-out.** Dispatch distinct subagents via `delegate` for:
   - **Code review and adversarial interrogation (`interrogate`):** concurrent reviewers across
     distinct model classes (`strong`, `fast`, `inherit`). Simulating reviewer personas in the
     parent context is strictly forbidden.
   - **Multi-candidate bakeoffs (`arena`):** parallel children, each in its own scratch path or git
     worktree.
   - **High-volume sweeps and test matrices (`swarm`):** offload bulk reads to children to guard the
     parent's context window. If your agent caps concurrency, dispatch everything in one turn and let
     the rest queue.
   - **Blinded evaluations (`eval`):** candidate attempts run through blinded children.
   - **Cross-model decision audits (`show-me-your-work`):** at least one auditor on a different model
     class than the executor.
3. **Candidate integration invariant.** Parallel candidate diffs from swarms, arenas, or fan-outs
   are never bulk-merged. Evaluate each candidate in isolation, rank by delta, then graft the winning
   changes sequentially — verifying and benchmarking each before starting the next
   (`principle-sequence-verifiable-units`).
4. **Subagent Reactive Wakeup and Watchdog Timeout Invariant.** Assume a child cannot message the
   parent mid-run and delivers exactly one result when it finishes:
   - If `delegate` returns immediately, **end the turn.** Dispatching *is* the yield.
   - **Polling is prohibited.** Never loop `delegate(status)` to wait, and never attach a status call
     to a turn that is meant to wait. Status is for diagnosis after a watchdog fires or an explicit
     failure.
   - **One watchdog per fan-out.** Before yielding, arm a timer —
     `schedule create --after 10m --prompt "Watchdog: subagents timed out"` — and cancel it once
     results land. If your scheduler can wake on a specific child's completion, prefer that.
   - **Teardown.** On partial results, record findings and end the turn; when all children are in,
     cancel the watchdog and synthesize. Diagnose a silent child with `delegate(status)`, then
     `delegate(cancel)` (its partial result still comes back). Read a child's transcript only for
     post-mortem, never while waiting.
   - **Primitive Boundary:** active heartbeat polling applies to external processes (`shell`, a cloud
     dispatcher), never to `delegate` children.
5. **Planning and Deliverable Artifact Scoping Matrix** (all paths under `artifacts/<task-slug>/`):
   - **Interactive State-Changing Playbooks (`Feature`, `Refactoring`, `Multi-phase`):** mandatory
     `implementation_plan.md` plus an `ask` for approval before coding; mandatory `walkthrough.md`
     with pass receipts on completion.
   - **Autonomous & Hillclimb Playbooks (`Autonomous run`, `Hillclimb`, `Swarm`):** unattended
     throughput invariant — auto-continue, no approval cards. Domain deliverables
     (`decision_trail.md`, `score.json`, `receipts/`) take precedence and are written incrementally
     so a later turn can resume from disk.
   - **Read-Only Investigation Playbooks (`Investigation`, `How`, `Why`, `Runtime Forensics`):**
     produce `investigation_report.md` and point the reply at it.
6. **Fix broken skills in place.** A skill whose steps reference a capability or path that no longer
   exists gets corrected at the point of failure, before continuing the task. Never work around it
   silently; never leave it for later.

## Surface precedence hierarchy

1. **Filesystem and shell (`read_file`/`edit_file`, `search`, `shell`)** — ground truth for code,
   configs, tests, exit codes, logs.
2. **Runtime capture (`shell`)** — test suites, CLIs, servers, profilers, process lifecycles.
3. **Browser (`browser`)** — strictly live UI interaction, DOM, layout, CSS, events, screenshots.

Per-role model classes live in `models.md` next to this file.
