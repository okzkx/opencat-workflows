# OpenCat Workflows

OpenCat Workflows packages four reusable repository-operation skills for `Claude Code` and `Cursor`.

It is designed for teams that want a repeatable workflow around:

- prerequisite checking before agent execution
- OpenSpec-assisted delivery
- reusable `git worktree` task isolation
- cleanup back to an idle, reusable repository state
- TODO-driven task queue execution

## Included Skills

- `opencat-check`: validate prerequisites, package manager choice, OpenSpec availability, and reusable worktree slots
- `opencat-cleanup`: converge interrupted OpenCat/OpenSpec work back to a safe idle state
- `opencat-task`: run a single change through purpose, apply, archive, merge, and return-to-idle
- `opencat-work`: pull tasks from `TODO.md` / `DONE.md` and execute them serially through `opencat-task`

## Who This Is For

This plugin is a good fit when you already:

- use repositories with Git and `git worktree`
- want AI agents to follow a strict task-isolation workflow
- optionally use OpenSpec to define and archive changes
- are willing to keep a lightweight `TODO.md` / `DONE.md` convention

It is not a generic project-management plugin, and it does not bundle OpenSpec itself.

## Repository Layout

```text
opencat-workflows/
├── .claude-plugin/plugin.json
├── skills/
├── .cursor/skills/
├── references/
├── scripts/
├── README.md
└── LICENSE
```

`skills/` is the source of truth. `.cursor/skills/` is a compatibility mirror generated from it.

## Prerequisites

Before using `opencat-task` or `opencat-work`, make sure the target repository has:

- Git available on `PATH`
- Node.js available on `PATH`
- the repository's preferred package manager available
- OpenSpec CLI available directly or through `npx openspec@latest`
- external OpenSpec skills available if you want full purpose/apply/archive orchestration

Details: `references/install-claude-code.md`, `references/install-cursor.md`, and `skills/opencat-task/references/dependency-openspec.md`.

## Install In Claude Code

1. Place `opencat-workflows/` directly under the `custom-plugins` marketplace root.
2. Ensure `custom-plugins/.claude-plugin/marketplace.json` lists `"source": "./opencat-workflows"`.
3. Install or enable it with `claude plugin install opencat-workflows@custom-plugins`.
4. Confirm the namespaced skills appear, for example `/opencat-workflows:opencat-task`.

Detailed notes: `references/install-claude-code.md`.

## Install In Cursor

1. Copy `.cursor/skills/` from this package into the target repository's `.cursor/skills/`.
2. If you edit canonical skills under `skills/`, run `scripts/sync-cursor-skills.ps1` to refresh the mirror.
3. Reopen or reload Cursor if the skills list does not refresh automatically.

Detailed notes: `references/install-cursor.md`.

## OpenSpec Dependency

This package intentionally treats OpenSpec as an external prerequisite instead of bundling it.

`opencat-task` expects these external capabilities to exist when purpose/apply/archive stages are used:

- `openspec-propose`
- `openspec-apply-change`
- `openspec-archive-change`

If they are missing, `opencat-check` should report that the environment is not fully ready.

## Usage Examples

- Start a repo session safely: `/opencat-workflows:opencat-check`
- Recover a half-finished run: `/opencat-workflows:opencat-cleanup`
- Execute one change end to end: `/opencat-workflows:opencat-task my-change-name`
- Consume the next entry from `TODO.md`: `/opencat-workflows:opencat-work`

## Troubleshooting

If the skills load but execution is incomplete, the usual causes are:

- OpenSpec CLI is missing
- the companion OpenSpec skills are not installed
- retained worktrees are detached, dirty, or attached to `trunk`
- the repository does not follow the expected idle-branch/task-branch convention
- `TODO.md` / `DONE.md` does not match the expected lightweight format

See `references/compatibility-matrix.md` and the skill-specific `references/` directories for operational detail.

## Compatibility Notes

- Primary target: `Claude Code` directory marketplace loading
- Secondary target: `Cursor` skills compatibility
- Not included in `0.1.0`: MCP distribution or bundled OpenSpec skills
