#!/usr/bin/env bash
# Usage: check-prereqs.sh <craft|audit>
# Run from the user project root (current working directory).
# Exit 0 when ready, 1 when a required user prerequisite or plugin file is missing.
set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh" || { echo "cannot load $SCRIPT_DIR/lib.sh" >&2; exit 2; }

USER_ROOT=$(pwd)
DIGEST="$PLUGIN_ROOT/rules-digest.md"
cmd="${1:-}"
case "$cmd" in
  craft)
    skills=(impeccable composition-patterns react-best-practices shadcn)
    user_files=(components.json)
    plugin_files=(skills/ui-craft/SKILL.md skills/ui-craft/patterns.md rules-digest.md)
    ;;
  audit)
    skills=(impeccable thermo-nuclear-code-quality-review react-best-practices composition-patterns shadcn)
    user_files=(.cursor/agents/thermo-nuclear-code-quality-review.md)
    plugin_files=(rules-digest.md skills/pr-audit/report-template.md skills/pr-audit/SKILL.md agents/pr-auditor.md)
    ;;
  *) echo "usage: check-prereqs.sh <craft|audit>" >&2; exit 2 ;;
esac

missing_user=0
missing_plugin=0
warn=0
unreviewed=()
for s in "${skills[@]}"; do
  if target_valid "$USER_ROOT/.cursor/skills/$s"; then echo "ok       skill $s"
  else echo "MISSING  skill $s (absent or invalid SKILL.md frontmatter)"; missing_user=1; fi
done
for f in "${user_files[@]}"; do
  if [ -s "$USER_ROOT/$f" ]; then echo "ok       $f"; else echo "MISSING  $f"; missing_user=1; fi
done
for f in "${plugin_files[@]}"; do
  if [ -s "$PLUGIN_ROOT/$f" ]; then echo "ok       plugin $f"
  else echo "MISSING  plugin $f"; missing_plugin=1; fi
done

if [ -f "$DIGEST" ] && [ -f "$LOCK" ]; then
  while IFS='|' read -r name _ _ sha _ reviewed; do
    grep -q "$sha" "$DIGEST" || { echo "WARN     rules-digest.md is stale: no $name SHA ${sha:0:7}"; warn=1; }
    case "$reviewed" in yes*) ;; *) unreviewed+=("$name") ;; esac
  done < <(lock_rows)
  # Informational only: an unreviewed pin is the shipped default, so it must not
  # turn every successful check into "READY with warnings".
  if [ "${#unreviewed[@]}" -gt 0 ]; then
    echo "note     ${#unreviewed[@]} pinned source(s) not marked reviewed in the plugin's $LOCK (informational; does not affect READY)"
  fi
  while read -r p; do
    [ -e "$USER_ROOT/$p" ] || { echo "WARN     rules-digest.md points to missing $p"; warn=1; }
  done < <(grep -oE '\.cursor/[A-Za-z0-9_./-]+\.(md|mdc)' "$DIGEST" | sort -u)
fi

if [ "$missing_user" = 1 ]; then
  echo "NOT READY: prerequisites are missing in the current directory ($USER_ROOT). Follow the Prerequisites section of the craft-audit plugin README (https://github.com/kdjadeja21/craft-audit-plugin#prerequisites). Do not continue."
fi
if [ "$missing_plugin" = 1 ]; then
  echo "NOT READY: plugin files are missing under $PLUGIN_ROOT. Reinstall the craft-audit plugin."
fi
if [ "$missing_user" = 1 ] || [ "$missing_plugin" = 1 ]; then
  exit 1
fi
[ "$warn" = 1 ] && echo "READY with warnings" || echo "READY"
