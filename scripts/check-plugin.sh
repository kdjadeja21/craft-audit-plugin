#!/usr/bin/env bash
# Verify plugin shell scripts parse and plugin.json is valid JSON.
set -uo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fail=0

shopt -s nullglob
for f in "$ROOT"/scripts/*.sh; do
  if bash -n "$f"; then
    echo "ok bash -n ${f#"$ROOT"/}"
  else
    echo "FAIL bash -n ${f#"$ROOT"/}" >&2
    fail=1
  fi
done

manifest="$ROOT/.cursor-plugin/plugin.json"
if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$manifest"; then
  echo "ok plugin.json"
else
  echo "FAIL plugin.json is not valid JSON" >&2
  fail=1
fi

exit "$fail"
