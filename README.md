# agent-skills

My Hermes Agent setup, kept in version control: the operating rules in `SOUL.md`
and the `agent-roster` skill that defines the eleven subagent roles.

## What's here

```
SOUL.md                                        # the agent's identity + universal rules + roster pointer
skills/subagents/agent-roster/SKILL.md         # how to dispatch each role through delegate_task
skills/subagents/agent-roster/references/*.md  # 11 role briefs, one per agent
install.sh                                     # copy both into a HERMES_HOME
```

## The eleven agents

Each one is a **role**, not a process and not a profile. A role is realised as a
`delegate_task` subagent: a fresh conversation that knows nothing about the parent's
session, receives only the `goal` and `context` the parent writes, and returns a summary.

There is no `agent=` parameter on `delegate_task`. The role is carried by the brief the
child loads itself, as the first line of its context:

```
Act as the `advisor` agent. Load your role brief first:
    skill_view(name='agent-roster', file_path='references/advisor.md')
Follow it exactly. Then: <the task>
```

| Role | What it does | Policy | Mode |
|---|---|---|---|
| `plan` | Read-only architect; design tree, then a written plan for approval | sandbox | main+sub |
| `logic` | Invariants, decision tables, state machines, exhaustive coverage | sandbox | main+sub |
| `build` | TDD implementer, vertical slices at agreed seams | auto | main+sub |
| `surgical` | Minimal-diff bug fixes, root cause first, no surrounding refactors | sandbox | main+sub |
| `design` | UI/UX and design systems, states, a11y, light/dark parity | sandbox | main+sub |
| `scribe` | Keeps docs true and in sync with code and config | sandbox | main+sub |
| `tester` | Closes coverage gaps via TDD at public seams | auto | main+sub |
| `advisor` | Two-axis review (Standards + Spec), P1/P2/P3 with `file:line` + fix | sandbox | subagent-only |
| `hunter` | Whole-codebase sweep: bug classes, dead code, quality risks | sandbox | subagent-only |
| `sentinel` | Threat-model-first security audit, exploit paths, no fixes | sandbox | main+sub |
| `ship` | Release verdict SHIP/NO-SHIP with an evidence-backed gate table | sandbox | main+sub |

Pipeline: **plan** → (**logic**) → **build** → **tester** + **advisor** → **surgical**/**hunter**
→ (**sentinel**) → **scribe** → **ship**, with the human owning approval, commits and the release.

## Install

```bash
./install.sh              # into $HERMES_HOME (default ~/.hermes)
./install.sh --dry-run    # show what would be copied
```

`install.sh` copies `SOUL.md` and the skill into `$HERMES_HOME`, backing up any
existing `SOUL.md` first. Restart any running Hermes session afterwards so it re-reads
both.

## Notes

- The role rule lists are **derived** from each role's description — the source spec
  states how many rules each role carries but not their text. Each brief says so at the
  point of use; replace them when the originals turn up.
- `sandbox` maps to Hermes' default for subagents: worker threads get a non-interactive
  approval callback that auto-denies dangerous commands
  (`delegation.subagent_auto_approve` defaults to `false`). `auto` roles (`build`,
  `tester`) are the ones that may need that flag flipped — it is global, not per-role.
- No secrets belong in this repo. `SOUL.md` here has none, and `.gitignore` blocks the
  usual credential files.

## Licence

MIT — see `LICENSE`.
