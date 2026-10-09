# Per-role model classes. One line per role. Delete a line to fall back to the skill default.
#
# Three classes, so this file stays portable. Map them onto real model ids in your own agent
# configuration — never the other way round:
#   inherit — run on the model this conversation already uses. The default: the user picked that
#             model, and a delegate on a different one costs more or performs worse without them
#             seeing it happen.
#   strong  — the strongest model you can select. Judgment, design, multi-step reasoning, hard
#             debugging, ambiguous requirements.
#   fast    — a cheap, quick model. Mechanical, well-bounded work that is verifiable at a glance.
#
# A panel role takes a comma-separated list: one subagent runs per entry, so the list length sets
# the panel size. Keep panels small — a child is a real model call.

feature, refactoring: inherit
bug-fix: inherit
perf-issue: inherit
hillclimb: inherit
judgment and prose: inherit
hardest tasks: strong
how explorer: fast
how explainer: inherit
why investigators: fast
why synthesizer: inherit
reflect tooling: inherit
reflect judgment, divergent, synthesizer: inherit
arena runners: inherit, fast, strong
arena cross-judge pool: inherit, fast, strong
swarm workers: fast
architect runners: inherit, fast, strong
interrogate reviewers: strong, fast, inherit
