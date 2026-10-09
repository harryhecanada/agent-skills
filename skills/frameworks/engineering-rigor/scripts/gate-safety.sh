#!/bin/sh
# Run the safety gate on a shell command before executing it.
# Usage: gate-safety.sh "<shell command>"
# Prints the hook's JSON decision on stdout: {} = allow, {"decision":"force_ask"|"reject",...} = stop.
# Use it as the pre-flight in autonomous runs, where no human is watching the command.
A="$(cd "$(dirname "$0")/.." && pwd)"
cmd="$1"
[ -z "$cmd" ] && { echo "usage: gate-safety.sh \"<shell command>\"" >&2; exit 2; }
payload=$(python3 -c 'import json,sys; print(json.dumps({"toolCall":{"name":"shell","args":{"command":sys.argv[1]}}}))' "$cmd")
printf '%s' "$payload" | python3 "$A/skills/poteto-mode/scripts/hooks/pre_tool_safety.py"
