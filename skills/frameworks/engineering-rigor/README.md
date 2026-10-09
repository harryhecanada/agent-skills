# Engineering rigor

An agent-agnostic engineering workflow: 23 playbooks, 23 principle rules, and the leaf skills they
route to. Point your agent at this directory and it works the way a careful engineer works — match
the task to a playbook, work under named principles, delegate in isolated contexts, and prove the
result against the real artifact before declaring it done.

Nothing here names a specific agent, model vendor, or IDE. Skills refer to **capabilities**
(`shell`, `delegate`, `browser`, …) and you map them onto the tools your agent actually has. That
mapping is the only setup step, and it is documented in [`TOOLS.md`](TOOLS.md).

## Why

Agents writing code by default produce too much of it, verify too little of it, and report success
they have not checked. This skill set is the opposite posture: write less, verify against runtime
evidence, and keep the coordinator's context clean by pushing real work into isolated subagents.
It is a port of Lauren Tan's ([poteto](https://x.com/poteto)) pstack workflows, by way of Joel
Taroreh's agentic engineering framework, restructured to be platform-neutral.

## Install

Copy the directory into wherever your agent discovers skills, then point it at the entry skill:

```bash
skills-root/engineering-rigor/
```

The bundle keeps its own layout, so paths inside it are relative to the bundle root — `skills/why/SKILL.md`
means `<bundle>/skills/why/SKILL.md`. If your agent only discovers skills one level deep, register
the bundle's `SKILL.md` (the entry) or symlink individual leaf skills from `skills/`.

Verify:

```bash
ls skills/poteto-mode/playbooks | wc -l      # 23
sh scripts/gate-safety.sh "rm -rf /"         # a force_ask decision
python3 -m pytest tests/ -q                  # the suite for this skill set itself
```

## Layout

```
SKILL.md          the entry skill: contract + non-negotiables
TOOLS.md          capability vocabulary — read this first
rules/AGENTS.md   delegation, fan-out and verification invariants
rules/models.md   per-role model classes (inherit / strong / fast)
agents/           ready-made briefs for the subagents you dispatch
scripts/          command gates, runnable as CLIs
skills/           poteto-mode (the engine), 23 playbooks, 23 principles, and the leaf skills
tests/            catalog, hook and invariant tests for this skill set
```

## The two ways in

- [`skills/poteto-mode/SKILL.md`](skills/poteto-mode/SKILL.md) — **the engine.** A sticky mode: it
  matches the task to a playbook, copies the playbook's steps into a todo list, routes to leaf
  skills, and stays on until the user opts out. Read it in full before your first real step. Its
  **Non-negotiables** list is the trigger table for everything else.
- Everything else is situational. The mode runs the leaf skills for you when a step needs one:
  `how`, `why`, `recall`, `architect`, `arena`, `swarm`, `interrogate`, `deslop`, `no-comments`,
  `unslop`, `technical-writing`, `tdd`, `teach`, `reflect`, `blast-radius`, `figure-it-out`,
  `automate-me`, `loop`, `show-me-your-work`, `create-verification-skill`,
  `maintain-verification-skill`, `typescript-best-practices`, `bro`, and the 23 `principle-*` rules.

## What was changed from upstream

- **Capabilities instead of tools.** Every platform-specific tool reference became a capability
  (`shell`, `delegate`, `schedule`, `ask`, `browser`, `sessions`), mapped in `TOOLS.md`.
- **Artifacts are files.** Deliverables go to `artifacts/<task-slug>/` under a name the human can
  open, rather than to a product's artifact store. Feedback is an `ask`, not an artifact flag.
- **A generic subagent contract.** Children get one result and cannot ask questions mid-run, so the
  dispatch-then-yield rule and a watchdog replace product-specific wakeup mechanics.
- **Hooks are CLIs.** `scripts/gate-safety.sh` and `scripts/gate-delegation.sh` do the work the
  upstream hook scripts did, without a lifecycle-hook system.
- **The cloud worker was removed.** Upstream's Cloud Run backend imports one vendor's agent SDK, so
  it cannot live in a platform-neutral bundle. What remains of that skill is the part that is
  genuinely general: partition → fan out → aggregate → report.
- **Model classes replace model names.** `pro` / `flash` / `inherit` became `strong` / `fast` /
  `inherit`, mapped per role in `rules/models.md`.

## Provenance

MIT. The workflows originate in Lauren Tan's pstack (Cursor) and were extended into an agentic
engineering framework by Joel Taroreh; this port keeps their structure and rules, and rewrites the
platform layer. See [`LICENSE`](LICENSE).

If you shape a skill here, keep the two rules above: name capabilities, never products, and prefer
deleting a step over adding a platform-specific one.
