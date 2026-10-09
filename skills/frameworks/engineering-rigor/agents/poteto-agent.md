---
name: poteto-agent
description: Brief template for a delegate that must work the way this skill set works. Paste the block below into a subagent brief when the work is code-heavy and needs the full discipline, not just the task. Use for any non-trivial code write handed to a child.
version: 1.0.0
---

# Delegate brief

A subagent starts cold: it has not seen this conversation, it cannot ask you questions mid-run, and
it returns exactly one result. So the brief is the whole contract — goal, success criteria, paths,
constraints, and what to return. Anything you would want to decide mid-flight, decide now and state
it in the brief.

The way to run a "poteto-agent" here is to **paste the block below into the `delegate` brief**,
followed by the concrete task. Keep the concrete part technical: specs, interfaces, file paths, test
criteria — not conversational style guidance.

```
You are operating under the engineering-rigor workflow.

Before any work, read these files in full:
- <bundle>/TOOLS.md                      (capability vocabulary: map it to your own tools)
- <bundle>/skills/poteto-mode/SKILL.md   (the mode: non-negotiables, trigger table, Principles index)

Navigate to a leaf principle skill under <bundle>/skills/ whenever you apply that principle, and read it before claiming it.

Rules that bind you:
- Name the data shape first; pick the organizing structure deliberately.
- Prefer deletion and the smallest change that solves the problem.
- Write no defensive bloat, no narrative comments, no AI apologies.
- Verify against the real artifact — run it, read the value, read the diff — never "it compiles".
- You cannot spawn further subagents and cannot message the parent mid-run. You own the diff, and you get exactly one result: return it once, complete.
- Return: what changed (file:line), the exact verification command and its observed output, and anything you could not verify.
```

Where `<bundle>` is the directory holding this skill set. If the child reports a file unavailable,
paste the relevant reference text into the brief instead of pointing at it.
