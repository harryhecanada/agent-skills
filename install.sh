#!/usr/bin/env bash
# Install SOUL.md and the agent-roster skill into a Hermes home.
#
#   ./install.sh              install into $HERMES_HOME (default ~/.hermes)
#   ./install.sh --dry-run    print what would happen, touch nothing
#   HERMES_HOME=/path ./install.sh
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SKILL_NAME="agent-roster"
DEST_SKILL="$HERMES_HOME/skills/subagents/$SKILL_NAME"
STAMP="$(date +%Y%m%d_%H%M%S)"
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    -h|--help) sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '%s\n' "$*"; }
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    say "  would: $*"
  else
    "$@"
  fi
}

if [ ! -d "$HERMES_HOME" ]; then
  say "error: HERMES_HOME does not exist: $HERMES_HOME" >&2
  say "       create it first, or set HERMES_HOME to an existing Hermes home." >&2
  exit 1
fi

say "source:      $SRC_DIR"
say "HERMES_HOME: $HERMES_HOME"
[ "$DRY_RUN" -eq 1 ] && say "mode:        DRY RUN (nothing will be written)"
say ""

# --- SOUL.md -----------------------------------------------------------------
if [ -f "$HERMES_HOME/SOUL.md" ]; then
  if cmp -s "$SRC_DIR/SOUL.md" "$HERMES_HOME/SOUL.md"; then
    say "SOUL.md: already identical, leaving it alone"
  else
    say "SOUL.md: differs — backing up to SOUL.md.bak.$STAMP"
    run cp -p "$HERMES_HOME/SOUL.md" "$HERMES_HOME/SOUL.md.bak.$STAMP"
    run cp "$SRC_DIR/SOUL.md" "$HERMES_HOME/SOUL.md"
    say "SOUL.md: replaced"
  fi
else
  run cp "$SRC_DIR/SOUL.md" "$HERMES_HOME/SOUL.md"
  say "SOUL.md: installed"
fi

# --- skill -------------------------------------------------------------------
run mkdir -p "$HERMES_HOME/skills/subagents"
if [ -d "$DEST_SKILL" ]; then
  say "skill:    $DEST_SKILL exists — backing up to $DEST_SKILL.bak.$STAMP"
  run mv "$DEST_SKILL" "$DEST_SKILL.bak.$STAMP"
fi
run cp -r "$SRC_DIR/skills/subagents/$SKILL_NAME" "$DEST_SKILL"
say "skill:    installed to $DEST_SKILL"

say ""
if [ "$DRY_RUN" -eq 1 ]; then
  say "dry run complete — nothing was written."
else
  say "done. restart any running Hermes session so it re-reads SOUL.md and the skill."
  say "verify with:  hermes chat -q 'list the skills you have that mention agent-roster'"
fi
