# Capabilities

This skill set is written once and runs anywhere. It never names a product's tools. Where a step
says one of the capabilities below, use the tool your agent exposes for it — whatever it is called.

| capability | what it must do | names you may see |
|---|---|---|
| `shell` | run a command, return stdout/stderr and an exit code | shell, bash, terminal, exec, run_command |
| `read_file` | read a file's contents | read, view_file, cat |
| `write_file` | create or overwrite a file | write, create_file |
| `edit_file` | replace an exact string in an existing file | edit, replace, apply_patch |
| `search` | find files by name and text/regex across a tree | ripgrep (`rg`), grep, find |
| `delegate` | start an isolated subagent that runs its own tool loop and returns one result | task, subagent, spawn_agent, spawn_subagent, agent |
| `delegate(status)` / `delegate(cancel)` / `delegate(steer)` | inspect, stop, or course-correct running children | manage_subagents, task status |
| `schedule` | run something later, repeatedly, or on an event | cron, timer, scheduler, manage_task |
| `ask` | put a question to the human and wait for an answer | ask_question, clarify, user_ask |
| `browser` | drive a web page: navigate, read the DOM, click, type, screenshot | browser_subagent, playwright, CDP |
| `sessions` | read this conversation or past conversations, including tool calls | transcript, history, session store |
| `notify` | push a message to the human's device or channel (optional) | notifications, webhook |
| `model listing` | list the models selectable on this device (optional) | model list, provider config |

## Paths

| convention | meaning |
|---|---|
| `skills/` | the leaf skills in **this** skill set; a path like `skills/why/SKILL.md` is relative to the bundle root |
| `skills-root/` | wherever your agent discovers installed skills (e.g. `<home>/skills`); a project-local skill goes in `skills-root/<name>/` |
| `artifacts/<task-slug>/` | deliverables for the current task: plans, walkthroughs, reports, receipts, logs. Create it when the first deliverable exists; link files in your reply so the human can open them. |
| `scratch/` | throwaway working files |

## Rules

1. **Never invent a tool name.** If a capability has no match, say which one is missing and use the
   closest substitute, or do the step by other means and say how.
2. **Map once, at the start.** Before your first real step, write down the mapping you will use
   (`shell` → …, `delegate` → …). Every later step inherits it.
3. **`delegate` is asynchronous where the platform allows.** If it returns immediately, end your
   turn and let the result arrive; if it blocks, it returns the result directly. Never wrap it in a
   polling loop. See `rules/AGENTS.md`.
4. **A child gets one result.** Subagents usually cannot ask questions mid-run and cannot message
   the parent: everything a child needs goes in the brief, and its final message is the deliverable.
5. **Model classes, not model names.** Roles are assigned `inherit` (the conversation's model),
   `strong`, or `fast` — map those onto real models in `rules/models.md`, never the other way round.
6. **Artifacts are files.** No agent-specific artifact UI is assumed: a deliverable is a file the
   human can open, and asking for feedback is an `ask`, not an artifact flag.
