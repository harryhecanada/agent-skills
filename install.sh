#!/usr/bin/env bash
# Install skills from this repo into a skills root.
#
#   ./install.sh                              all skills into ./skills-root
#   SKILLS_HOME=/path/to/skills ./install.sh  another skills root
#   ./install.sh --only engineering-rigor     one skill, by leaf name
#   ./install.sh --dry-run                    print what would happen, touch nothing
#
# Skills are copied with their category path (skills/subagents/agent-roster -> <root>/subagents/agent-roster).
# Anything it would replace is moved aside to a timestamped .bak first.
#
# If your agent only discovers skills one level deep, flatten after install — the skill contents do
# not depend on where they sit.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_HOME="${SKILLS_HOME:-$PWD/skills-root}"
STAMP="$(date +%Y%m%d_%H%M%S)"
DRY_RUN=0
ONLY=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --only) shift; ONLY="${1:-}"; [ -z "$ONLY" ] && { echo "--only needs a skill name" >&2; exit 2; } ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

say() { printf '%s\n' "$*"; }
run() {
  if [ "$DRY_RUN" -eq 1 ]; then say "  would: $*"; else "$@"; fi
}

say "source:      $SRC_DIR"
say "SKILLS_HOME: $SKILLS_HOME"
[ -n "$ONLY" ] && say "only:        $ONLY"
[ "$DRY_RUN" -eq 1 ] && say "mode:        DRY RUN (nothing will be written)"
say ""

found=0
while IFS= read -r skill_md; do
  src="$(dirname "$skill_md")"
  rel="${src#"$SRC_DIR"/skills/}"
  name="$(basename "$src")"
  [ -n "$ONLY" ] && [ "$name" != "$ONLY" ] && continue
  found=$((found + 1))
  dest="$SKILLS_HOME/$rel"
  if [ -e "$dest" ]; then
    say "backup:   $rel exists — $dest.bak.$STAMP"
    run mv "$dest" "$dest.bak.$STAMP"
  fi
  run mkdir -p "$(dirname "$dest")"
  run cp -r "$src" "$dest"
  say "skill:    $rel installed"
# top-level skills only: skills/<category>/<skill>/SKILL.md. A skill may carry its own nested
# skills (engineering-rigor does); those travel with it and are not installed separately.
done < <(find "$SRC_DIR/skills" -mindepth 3 -maxdepth 3 -name SKILL.md -not -path '*/node_modules/*' | sort)

if [ "$found" -eq 0 ]; then
  say "no skills matched (--only $ONLY)" >&2
  exit 1
fi

say ""
if [ "$DRY_RUN" -eq 1 ]; then
  say "dry run complete — nothing was written."
else
  say "done. $found skill(s) installed into $SKILLS_HOME."
  say "verify:  ls \$SKILLS_HOME   (each skill keeps its SKILL.md)"
fi
