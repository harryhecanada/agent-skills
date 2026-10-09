#!/bin/sh
# Ask the delegation gate whether an edit must be delegated to a subagent.
# Usage: gate-delegation.sh <target-file> [new-content-file]
#   new-content-file holds the replacement content; omit it to gate a new empty file.
# Prints the hook's JSON decision: {} = the coordinator may write it directly.
A="$(cd "$(dirname "$0")/.." && pwd)"
path="$1"
content_file="$2"
[ -z "$path" ] && { echo "usage: gate-delegation.sh <target-file> [new-content-file]" >&2; exit 2; }
payload=$(python3 - "$path" "$content_file" <<'PY'
import json, sys
path, cf = sys.argv[1], sys.argv[2]
content = ""
if cf:
    try:
        content = open(cf, encoding="utf-8").read()
    except OSError:
        content = ""
print(json.dumps({"toolCall": {"name": "write_file", "args": {"path": path, "content": content}}}))
PY
)
printf '%s' "$payload" | python3 "$A/skills/poteto-mode/scripts/hooks/pre_tool_delegation.py"
