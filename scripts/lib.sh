#!/usr/bin/env bash
# Shared helpers for check-prereqs.sh.
# Plugin root is the parent of this scripts/ directory, resolved from this file.

_LIB_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PLUGIN_ROOT=$(cd "$_LIB_DIR/.." && pwd)
LOCK="$PLUGIN_ROOT/skills.lock.md"

lock_rows() {
  awk -F'|' '/^\| *`/ {
    for (i = 2; i <= 7; i++) { gsub(/`/, "", $i); gsub(/^ +| +$/, "", $i) }
    print $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7
  }' "$LOCK"
}

has_frontmatter() {
  local f="$1"
  [ -s "$f" ] && [ "$(head -n 1 "$f")" = "---" ]
}

# A directory target is valid when SKILL.md has name + description frontmatter.
# A file target is valid when it is non-empty and starts with frontmatter.
target_valid() {
  local t="$1"
  if [ -d "$t" ]; then
    has_frontmatter "$t/SKILL.md" \
      && sed -n '2,/^---$/p' "$t/SKILL.md" | grep -q '^name:' \
      && sed -n '2,/^---$/p' "$t/SKILL.md" | grep -q '^description:'
  else
    [ -f "$t" ] && has_frontmatter "$t"
  fi
}
