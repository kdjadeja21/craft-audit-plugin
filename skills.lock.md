# Skills lock

Pinned third-party sources the user installs into their project. This plugin does not vendor them and does not add an npm script. Install from the Prerequisites section of the README at these SHAs. Edit a SHA deliberately to update, then reinstall that row and refresh `rules-digest.md` if the digested rules changed.
`reviewed`: set to `yes (<name>, <date>)` after a person has read the installed files. `scripts/check-prereqs.sh` warns on `no`.

Targets are paths relative to the user project root.

| Skill | Source repo | Path in repo | Pinned SHA | Target | Reviewed |
|---|---|---|---|---|---|
| `impeccable` | `pbakaus/impeccable` | `.cursor/skills/impeccable` | `d631a8827f99414d2b6daba4ef08b7f8701751d7` | `.cursor/skills/impeccable` | no |
| `composition-patterns` | `vercel-labs/agent-skills` | `skills/composition-patterns` | `063bee94c3f4df8453406c830b0a7df0f2860278` | `.cursor/skills/composition-patterns` | no |
| `react-best-practices` | `vercel-labs/agent-skills` | `skills/react-best-practices` | `063bee94c3f4df8453406c830b0a7df0f2860278` | `.cursor/skills/react-best-practices` | no |
| `shadcn` | `shadcn-ui/ui` | `skills/shadcn` | `6ea090075cd537d3b792c6c1a625e2448b6ede26` | `.cursor/skills/shadcn` | no |
| `thermo-nuclear-skill` | `cursor/plugins` | `cursor-team-kit/skills/thermo-nuclear-code-quality-review` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/skills/thermo-nuclear-code-quality-review` | no |
| `thermo-nuclear-agent` | `cursor/plugins` | `cursor-team-kit/agents/thermo-nuclear-code-quality-review.md` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/agents/thermo-nuclear-code-quality-review.md` | no |
| `rule-no-inline-imports` | `cursor/plugins` | `cursor-team-kit/rules/no-inline-imports.mdc` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/rules/no-inline-imports.mdc` | no |
| `rule-typescript-exhaustive-switch` | `cursor/plugins` | `cursor-team-kit/rules/typescript-exhaustive-switch.mdc` | `ccb5507cec1546dc88135c1139c811e6c59115ba` | `.cursor/rules/typescript-exhaustive-switch.mdc` | no |
