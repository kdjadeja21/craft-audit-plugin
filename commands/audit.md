---
name: audit
description: Read-only review of a GitHub pull request against its intent and the shared rules digest.
---

# /audit

Usage: `/audit <PR URL> [--post]`

Run this from the user project root so the prerequisite check sees that directory.

1. Parse owner, repo and PR number from the URL (`https://github.com/<owner>/<repo>/pull/<n>`). A bare number or branch is accepted only if the repo resolves unambiguously from the working copy's `origin`; otherwise stop and ask for the URL.
2. Locate this plugin's root: the directory that contains `.cursor-plugin/plugin.json` with `"name": "craft-audit"` (the same directory as `commands/audit.md`). Run `bash "<plugin-root>/scripts/check-prereqs.sh" audit`. If it fails, stop, change nothing, and point the user at the Prerequisites section of this plugin's README. Do not install skills.
3. Delegate to the `pr-auditor` agent (`agents/pr-auditor.md`, plugin-relative), which follows the `pr-audit` skill (`skills/pr-audit/SKILL.md`). Pass owner, repo, number and whether `--post` was given.
4. Read-only unless `--post` was given. Print the agent's report as the final output.

This command is independent of `/craft`: do not build or modify code. There is no `/setup` command.
