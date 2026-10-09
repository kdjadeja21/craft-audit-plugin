# craft-audit

A Cursor plugin that adds two commands:

- `/craft` builds UI in a Next.js project from a ticket or requirement, using the `ui-craft` skill.
- `/audit` reviews a GitHub pull request against its stated intent and the shared rules digest. It is read-only unless you pass `--post`.

The commands do not call each other. There is no `/setup` command. Third-party skills, rules, and the thermo-nuclear agent are prerequisites you install in the project you are working on. This repository does not vendor them.

## Install

Install from Customize once this repository is on the Cursor Marketplace or a team marketplace. Cursor reads `.cursor-plugin/plugin.json` and discovers `commands/`, `skills/`, and `agents/`.

### Local install

Copy the plugin into Cursor's local plugin directory. Cursor does not load a symlink that points outside that folder.

```bash
mkdir -p ~/.cursor/plugins/local
rm -rf ~/.cursor/plugins/local/craft-audit
cp -R /path/to/craft-audit-plugin ~/.cursor/plugins/local/craft-audit
```

Restart Cursor, or run **Developer: Reload Window**. In Customize, confirm the `craft` and `audit` commands, the `ui-craft` and `pr-audit` skills, and the `pr-auditor` agent.

If `/craft` and `/audit` are missing from the `/` menu but the plugin shows in Customize: make sure Settings → **Include third-party Plugins, Skills, and other configs** is on, then run **Developer: Reload Window** (or fully quit and restart Cursor). Plugin commands depend on that toggle and the slash menu can keep a stale cache until reload. See the [plugins reference](https://cursor.com/docs/reference/plugins) and [forum thread](https://forum.cursor.com/t/cursor-3-9-8-doesnt-surface-plugin-commands-md-in-the-slash-menu-both-for-local-and-marketplace-plugins/164112).

## Prerequisites

`/craft` and `/audit` check the current working directory and stop when a required skill or file is missing. Run them from the project root. The check does not install anything. If it fails, follow the steps below, then run the command again.

The project needs Next.js 16, Tailwind 4, and shadcn. For a new app:

```bash
npx create-next-app@16 . --typescript --tailwind --eslint --app --no-src-dir
npx shadcn@latest init --defaults --yes
```

`shadcn init` must leave a `components.json` at the project root, with Tailwind 4, `app/globals.css`, and CSS variables. `/craft` treats a missing `components.json` as not ready.

Install each pinned third-party tree into the project (paths are relative to the project root). SHAs match [skills.lock.md](skills.lock.md).

```bash
set -e

install_pinned() {
  local repo="$1" sha="$2" path="$3" dest="$4"
  local tmp rc
  tmp=$(mktemp -d)
  git clone -q --depth 1 --filter=blob:none --sparse --no-checkout "https://github.com/${repo}.git" "$tmp" \
    && git -C "$tmp" sparse-checkout set --no-cone "/${path}" \
    && git -C "$tmp" fetch -q --depth 1 --filter=blob:none origin "$sha" \
    && git -C "$tmp" checkout -q "$sha" \
    && rm -rf "$dest" \
    && mkdir -p "$(dirname "$dest")" \
    && cp -R "$tmp/$path" "$dest"
  rc=$?
  rm -rf "$tmp"
  return "$rc"
}

install_pinned pbakaus/impeccable d631a8827f99414d2b6daba4ef08b7f8701751d7 .cursor/skills/impeccable .cursor/skills/impeccable
install_pinned vercel-labs/agent-skills 063bee94c3f4df8453406c830b0a7df0f2860278 skills/composition-patterns .cursor/skills/composition-patterns
install_pinned vercel-labs/agent-skills 063bee94c3f4df8453406c830b0a7df0f2860278 skills/react-best-practices .cursor/skills/react-best-practices
install_pinned shadcn-ui/ui 6ea090075cd537d3b792c6c1a625e2448b6ede26 skills/shadcn .cursor/skills/shadcn
install_pinned cursor/plugins ccb5507cec1546dc88135c1139c811e6c59115ba cursor-team-kit/skills/thermo-nuclear-code-quality-review .cursor/skills/thermo-nuclear-code-quality-review
install_pinned cursor/plugins ccb5507cec1546dc88135c1139c811e6c59115ba cursor-team-kit/agents/thermo-nuclear-code-quality-review.md .cursor/agents/thermo-nuclear-code-quality-review.md
install_pinned cursor/plugins ccb5507cec1546dc88135c1139c811e6c59115ba cursor-team-kit/rules/no-inline-imports.mdc .cursor/rules/no-inline-imports.mdc
install_pinned cursor/plugins ccb5507cec1546dc88135c1139c811e6c59115ba cursor-team-kit/rules/typescript-exhaustive-switch.mdc .cursor/rules/typescript-exhaustive-switch.mdc
```

| Skill | Source | Pinned SHA | Copy to |
|---|---|---|---|
| impeccable | `pbakaus/impeccable` `.cursor/skills/impeccable` | `d631a8827f99414d2b6daba4ef08b7f8701751d7` | `.cursor/skills/impeccable` |
| composition-patterns | `vercel-labs/agent-skills` `skills/composition-patterns` | `063bee94c3f4df8453406c830b0a7df0f2860278` | `.cursor/skills/composition-patterns` |
| react-best-practices | `vercel-labs/agent-skills` `skills/react-best-practices` | `063bee94c3f4df8453406c830b0a7df0f2860278` | `.cursor/skills/react-best-practices` |
| shadcn | `shadcn-ui/ui` `skills/shadcn` | `6ea090075cd537d3b792c6c1a625e2448b6ede26` | `.cursor/skills/shadcn` |
| thermo-nuclear skill | `cursor/plugins` `cursor-team-kit/skills/thermo-nuclear-code-quality-review` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/skills/thermo-nuclear-code-quality-review` |
| thermo-nuclear agent | `cursor/plugins` `cursor-team-kit/agents/thermo-nuclear-code-quality-review.md` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/agents/thermo-nuclear-code-quality-review.md` |
| no-inline-imports | `cursor/plugins` `cursor-team-kit/rules/no-inline-imports.mdc` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/rules/no-inline-imports.mdc` |
| typescript-exhaustive-switch | `cursor/plugins` `cursor-team-kit/rules/typescript-exhaustive-switch.mdc` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/rules/typescript-exhaustive-switch.mdc` |

`/craft` requires impeccable, composition-patterns, react-best-practices, shadcn, and `components.json`. `/audit` requires impeccable (referenced by `rules-digest.md`), react-best-practices, composition-patterns, shadcn, the thermo-nuclear skill, and the thermo-nuclear agent. The rules digest also points at the two rule files; a missing rule is a warning, not a hard failure.

After you have read an installed tree, set its `Reviewed` cell to `yes (<name>, <date>)` in `skills.lock.md`. That file belongs to the plugin install (for a local install, `~/.cursor/plugins/local/craft-audit/skills.lock.md`), not to your app project; the check reads it from the plugin root. Copying the plugin again overwrites your edit, so re-apply it or edit your source clone before copying. Until a row is marked reviewed, the prerequisite check prints one informational `note` line and still reports `READY` when the required files exist.

## Usage

From the project root:

```text
/craft TICKET-123
/craft <requirement text>
/audit https://github.com/<owner>/<repo>/pull/<n>
/audit https://github.com/<owner>/<repo>/pull/<n> --post
```

`/craft` plans before editing and prints a structured summary. `/audit` prints the report in chat. `--post` is the only write: one pull-request review comment. The verdict stays in the comment body.

Both commands run `scripts/check-prereqs.sh` from this plugin. The script resolves the plugin root from its own path and checks skills in the current directory. It does not look for `.cursor/scripts` or an npm script in the project.

## File layout

```text
.cursor-plugin/plugin.json    manifest
commands/craft.md             /craft
commands/audit.md             /audit
skills/ui-craft/              SKILL.md, patterns.md
skills/pr-audit/              SKILL.md, report-template.md
agents/pr-auditor.md          read-only /audit agent
scripts/check-prereqs.sh      user-project prerequisite check
scripts/lib.sh                shared helpers
scripts/check-plugin.sh       bash -n and plugin.json check
skills.lock.md                pinned third-party SHAs
rules-digest.md               shared rule pointers
rules/                        empty; rules are installed in the user project
LICENSE                       MIT
```

`${CURSOR_PLUGIN_ROOT}` is expanded only in MCP and hook command values. This plugin has neither, so commands use paths relative to the plugin root and the shell scripts locate that root from `BASH_SOURCE`.

## License

This plugin is MIT. See [LICENSE](LICENSE).

impeccable, composition-patterns, react-best-practices, shadcn, and the cursor-team-kit skill, agent, and rules are not included in this repository. Install them from the upstream repositories at the SHAs above. Their licenses stay with those projects.
