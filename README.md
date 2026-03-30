# OpenCat Workflows

```
 /\_/\___________________________________________________________ __
( o.o )___________________________________________________________) 
```

[English](README.md) | [简体中文](doc/README.zh-CN.md)

Reusable repository-operation skills for `Claude Code` and `Cursor`, built around a strict, repeatable workflow for agent-driven changes.

> Use this package when you want AI agents to check prerequisites, work in isolated `git worktree` task branches, optionally coordinate with OpenSpec, and always clean up back to a reusable idle state.

## Highlights


| Area               | What it gives you                                                                                           |
| ------------------ | ----------------------------------------------------------------------------------------------------------- |
| Safer starts       | Validate Git, Node.js, package manager, OpenSpec availability, and reusable worktree slots before execution |
| Task isolation     | Run each change inside a predictable `git worktree`-based workflow                                          |
| Recoverability     | Clean up interrupted runs and converge the repo back to a safe idle state                                   |
| Queue execution    | Pull work from `TODO.md` and process tasks serially                                                         |
| Dual compatibility | Maintain canonical skills for `Claude Code` and a mirrored set for `Cursor`                                 |


## Included Skills


| Skill             | Purpose                                                                                            |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| `opencat-check`   | Validate prerequisites, package manager choice, OpenSpec availability, and reusable worktree slots |
| `opencat-cleanup` | Converge interrupted OpenCat or OpenSpec work back to a safe idle state                            |
| `opencat-task`    | Run one change through purpose, apply, archive, merge, and return-to-idle                          |
| `opencat-work`    | Pull tasks from `TODO.md` / `DONE.md` and execute them serially through `opencat-task`             |


## Good Fit For

This package is a good fit if your team already:

- uses Git and `git worktree`
- wants AI agents to follow a strict task-isolation workflow
- optionally uses OpenSpec to define and archive changes
- is comfortable maintaining a lightweight `TODO.md` / `DONE.md` convention

It is not a general project-management plugin, and it does not bundle OpenSpec itself.

## Quick Start


| Environment   | What to do                                                                                                                                          |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Claude Code` | Place `opencat-workflows/` under your `custom-plugins` marketplace root, make sure the marketplace manifest points to it, then install or enable it |
| `Cursor`      | Copy `.cursor/skills/` into the target repository and refresh the mirrored skills when canonical files change                                       |


Detailed setup guides:

- `references/install-claude-code.md`
- `references/install-cursor.md`

## Prerequisites

Before using `opencat-task` or `opencat-work`, make sure the target repository has:

- Git available on `PATH`
- Node.js available on `PATH`
- the repository's preferred package manager available
- OpenSpec CLI available directly or through `npx openspec@latest`
- external OpenSpec skills available if you want full purpose/apply/archive orchestration

Further details:

- `references/install-claude-code.md`
- `references/install-cursor.md`
- `skills/opencat-task/references/dependency-openspec.md`

## Installation

### Claude Code

1. Place `opencat-workflows/` directly under the `custom-plugins` marketplace root.
2. Ensure `custom-plugins/.claude-plugin/marketplace.json` lists `"source": "./opencat-workflows"`.
3. Install or enable it with `claude plugin install opencat-workflows@custom-plugins`.
4. Confirm the namespaced skills appear, for example `/opencat-workflows:opencat-task`.

See `references/install-claude-code.md` for the full notes.

### Cursor

1. Copy `.cursor/skills/` from this package into the target repository's `.cursor/skills/`.
2. If you edit canonical skills under `skills/`, run `scripts/sync-cursor-skills.ps1` to refresh the mirror.
3. Reopen or reload Cursor if the skills list does not refresh automatically.

See `references/install-cursor.md` for the full notes.

## OpenSpec Dependency

This package intentionally treats OpenSpec as an external prerequisite instead of bundling it.

When `opencat-task` uses purpose, apply, and archive stages, it expects these external capabilities to exist:

- `openspec-propose`
- `openspec-apply-change`
- `openspec-archive-change`

If they are missing, `opencat-check` should report that the environment is not fully ready.

## Usage Examples

```text
/opencat-workflows:opencat-check
/opencat-workflows:opencat-cleanup
/opencat-workflows:opencat-task my-change-name
/opencat-workflows:opencat-work
```

- Start a repo session safely with `opencat-check`
- Recover a half-finished run with `opencat-cleanup`
- Execute one change end to end with `opencat-task`
- Consume the next entry from `TODO.md` with `opencat-work`

## Repository Layout

```text
opencat-workflows/
├── .claude-plugin/plugin.json
├── skills/
├── .cursor/skills/
├── references/
├── scripts/
├── doc/
│   └── README.zh-CN.md
├── README.md
└── LICENSE
```

`skills/` is the source of truth. `.cursor/skills/` is a compatibility mirror generated from it.

## Troubleshooting

If the skills load but execution is incomplete, the usual causes are:

- OpenSpec CLI is missing
- the companion OpenSpec skills are not installed
- retained worktrees are detached, dirty, or attached to `trunk`
- the repository does not follow the expected idle-branch or task-branch convention
- `TODO.md` / `DONE.md` does not match the expected lightweight format

For operational detail, see:

- `references/compatibility-matrix.md`
- skill-specific `references/` directories

## Compatibility Notes

- Primary target: `Claude Code` directory marketplace loading
- Secondary target: `Cursor` skills compatibility
- Not included in `0.1.0`: MCP distribution or bundled OpenSpec skills

