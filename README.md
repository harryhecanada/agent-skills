# agent-skills

A catalogue of agent skills, kept in version control. Each skill is plain markdown plus whatever
reference files and scripts it needs, so it can be dropped into any agent that discovers skills from
a directory.

**Two rules hold the whole repo together:**

1. **Name capabilities, never products.** A skill says `shell`, `delegate`, `browser` — not one
   agent's tool names. The consumer maps them onto the tools it actually has.
2. **Nothing agent-specific.** No vendor, IDE, model, or personal setup leaks into a skill. A skill
   here should be installable by anyone, on anything.

## What's here

```
skills/
  frameworks/
    engineering-rigor/          rigorous engineering workflow: 23 playbooks, 23 principles,
                                delegation invariants, capability vocabulary, command gates
  subagents/
    agent-roster/               eleven named subagent roles: briefs, dispatch shape, output schemas
                                and the pipeline that orders them
install.sh                      copy skills into a skills root
```

### `engineering-rigor`

The how: match a task to a playbook, work under named principles, delegate in isolated contexts,
and prove the result against the real artifact before claiming it works. A port of poteto's pstack
workflows. Start at its
[`SKILL.md`](skills/frameworks/engineering-rigor/SKILL.md), then read
[`TOOLS.md`](skills/frameworks/engineering-rigor/TOOLS.md) — that file is what makes the rest
portable, because it defines the capability vocabulary and how to map it onto your own tools.
It carries its own test suite (`pytest tests/`) and command gates
(`scripts/gate-safety.sh`, `scripts/gate-delegation.sh`).

### `agent-roster`

The who: eleven roles — `plan`, `logic`, `build`, `surgical`, `design`, `scribe`, `tester`,
`advisor`, `hunter`, `sentinel`, `ship` — each a brief a dispatched child loads and follows. The
skill carries the dispatch shape, the per-role output schemas, and the pipeline that keeps review
from collapsing into self-review.

The two are designed to be used together: the roster names who runs the work, `engineering-rigor`
names how any of them should work. A dispatch brief can carry both — name the role, then require
the rigor rule that matters for that step.

## Install

```bash
./install.sh                        # all skills into ./skills-root (create it first)
SKILLS_HOME=/path/to/skills ./install.sh
./install.sh --dry-run              # show every action, write nothing
./install.sh --only engineering-rigor
```

`install.sh` copies each skill directory into `$SKILLS_HOME` (default `$PWD/skills-root`), keeping
the category path, and moves anything it would replace to a timestamped `.bak`.

If your agent only discovers skills one level deep, flatten the category directory when installing:
`skills/subagents/agent-roster` becomes `<skills-root>/agent-roster`. The skill contents do not
depend on where they sit; only the entry `SKILL.md` needs to be discoverable.

## Adding a skill

```
skills/<category>/<skill-name>/SKILL.md      # frontmatter: name, description, version
skills/<category>/<skill-name>/references/   # optional, read on demand
skills/<category>/<skill-name>/scripts/      # optional, runnable
```

- `description` is the trigger: say what it does and when to use it, because that line is all a
  consumer sees before deciding.
- Keep the body short and imperative; push detail into `references/` and read it when needed.
- Reference other files by relative path, so the skill works wherever it is installed.
- No credentials, no machine paths, no product names.

## Licence

MIT — see [`LICENSE`](LICENSE). `skills/frameworks/engineering-rigor` carries upstream's MIT licence
and credits Lauren Tan's pstack workflows and Joel Taroreh's agentic engineering framework.
