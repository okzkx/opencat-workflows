# OpenCat Workflows

```text
 /\_/\___________________________________________________________ __
( o.o )___________________________________________________________)
```

[English](README.md) | [简体中文](doc/README.zh-CN.md)

`OpenCat Workflows` is a reusable workflow package for `Claude Code` and `Cursor`.
The recommended distribution model is to install it as a `Claude Code` plugin. If marketplace installation is not available in your environment, you can copy the directories under `skills/` into your own skills folder as a fallback.
Version `0.2.0` standardizes the current execution model around five skills:

- `opencat-check` for environment and topology readiness
- `opencat-cleanup` for residue recovery and idle-state convergence
- `opencat-task` for one isolated OpenSpec change flow
- `opencat-work` for serial `TODO.md` execution
- `opencat-agent` for cat identity generation used by task subagents

This package does not bundle OpenSpec itself. Full task execution still depends on external OpenSpec CLI and OpenSpec skills being available in the target environment.

## Included Skills

| Skill | Role in `0.2.0` |
|------|------|
| `opencat-check` | Verifies Git, Node.js, package manager, OpenSpec availability, and retained worktree topology |
| `opencat-cleanup` | Finishes interrupted work safely and returns retained worktrees to their paired `opencat/idle/<slot-name>` branches |
| `opencat-task` | Runs one OpenSpec task through propose, apply, archive, merge, and final cleanup in an isolated worktree |
| `opencat-work` | Reads activated items from `TODO.md`, creates one task subagent at a time, delegates real execution to `opencat-task`, then finalizes the queue with cleanup and repository publish |
| `opencat-agent` | Generates or reuses a cat persona, persists it as an Agent file, and provides Git identity for the task subagent |

## Execution Model

### Standalone Task

Use this when you already know the exact change name.

1. Run `opencat-check`
2. Run `opencat-task <change-name>`
3. Let `opencat-task` call `opencat-cleanup` at the start and end of the flow

`opencat-task` is the executor. `opencat-check` is the readiness gate.

### TODO Queue

Use this when work should be pulled from `TODO.md`.

1. Run `opencat-work`
2. `opencat-work` runs `opencat-check`
3. `opencat-work` runs `opencat-cleanup`
4. `opencat-work` selects one activated task
5. `opencat-work` calls `opencat-agent` to generate or reuse a cat identity
6. The task subagent runs `opencat-task`
7. `opencat-work` updates `TODO.md` and `DONE.md`
8. `opencat-work` finishes with one more `opencat-cleanup`
9. After final cleanup, `opencat-work` performs the final repository `git commit` and `git push` when needed

Only one task subagent is allowed at a time. Queue execution is intentionally serial.

## Requirements

Before using `opencat-task` or `opencat-work`, the target repository should provide:

- Git on `PATH`
- Node.js on `PATH`
- the repository's preferred package manager
- OpenSpec CLI directly or through `npx openspec@latest`
- the OpenSpec skills required by the task flow
- a detectable `trunk` branch such as `main` or `master`

For best results, the repository should also follow these conventions:

- retained worktree slots that can be reused
- idle branches named like `opencat/idle/<slot-name>`
- task branches named like `opencat/<change-name>`
- lightweight `TODO.md` and `DONE.md` files when `opencat-work` is used

## Install

### Claude Code

Recommended path:

1. Place `opencat-workflows/` under your local `custom-plugins` marketplace root
2. Add or verify `"source": "./opencat-workflows"` in `custom-plugins/.claude-plugin/marketplace.json`
3. Run `claude plugin install opencat-workflows@custom-plugins`
4. Confirm `/opencat-workflows:opencat-check`, `/opencat-workflows:opencat-cleanup`, `/opencat-workflows:opencat-task`, `/opencat-workflows:opencat-work`, and `/opencat-workflows:opencat-agent` are visible

Fallback path:

1. Copy each directory under `skills/` into your own skills folder, such as `~/.claude/skills/`
2. Keep the original folder names, for example `skills/opencat-task/` -> `~/.claude/skills/opencat-task/`
3. Reload the client and confirm the skills are discoverable

Detailed notes: `references/install-claude-code.md`

### Cursor

Cursor can consume the same canonical skills directly:

1. Copy each directory under `skills/` into the target repository's `.cursor/skills/`
2. Keep the original folder names so discovery remains stable
3. Reload Cursor if the skills do not appear immediately
4. Confirm `opencat-check`, `opencat-cleanup`, `opencat-task`, `opencat-work`, and `opencat-agent` are discoverable

## Quick Start

For the shortest first run:

1. Run `/opencat-workflows:opencat-check`
2. Create `TODO.md`
3. Run `/opencat-workflows:opencat-work`

Minimal `TODO.md` example:

```markdown
# TODO

## P1 >
- My first task
```

`opencat-work` only picks activated items, so keep the `>` marker on the section or task you want to run.

## Basic Commands

```text
/opencat-workflows:opencat-check
/opencat-workflows:opencat-cleanup
/opencat-workflows:opencat-task my-change-name
/opencat-workflows:opencat-work
```

`opencat-agent` normally runs as an internal dependency of `opencat-work`, not as the main entrypoint for users.

## TODO and DONE Conventions

`opencat-work` only executes explicitly activated items.

- `## P1 >` means the whole section is active
- `- > Task A` means that single task is active
- items without `>` remain backlog only
- backlog items must not be auto-activated or auto-executed
- section activation markers are read-only for `opencat-work`
- when rewriting `TODO.md`, `opencat-work` may only touch task lines; section header lines must remain unchanged exactly as written
- before saving `TODO.md`, `opencat-work` should compare the section header snapshot and reject any rewrite that changes `## P1 >` into `## P1` or any similar header mutation
- task activation markers may be managed by `opencat-work` inside an already active section to indicate the current task

Example:

```markdown
# TODO

## P1 >
- Task A
- Task B

## P2
- Backlog Task C
```

In this example, `Task A` and `Task B` are runnable. `Backlog Task C` is not.

`DONE.md` uses a lightweight append-only archive record written by `opencat-work`. If no custom path is specified, the archive document should live under `.claude/docs/opencat/`:

```markdown
[2026-03-31 14:20] Task A-.claude/docs/opencat/task-a-20260331-1420.md
```

## Recommended Flows

### One Explicit Change

1. Run `opencat-check`
2. Run `opencat-task <change-name>`
3. Let the task flow finish its own cleanup

### Serial TODO Execution

1. Mark an active section or task in `TODO.md`
2. Run `opencat-work`
3. Wait for the serial queue to finish
4. Review `DONE.md`

If you changed canonical skills, copy the updated skill directories again before validating them in Cursor.

## Reference Project

- [`fly-cat`](https://github.com/okzkx/fly-cat): a real project that integrates `opencat-check` and `opencat-task` into its OpenCat workflow and documents the plugin-first installation path

## Repository Layout

```text
opencat-workflows/
├── .claude-plugin/
├── doc/
├── references/
├── scripts/
├── skills/
├── README.md
└── LICENSE
```

- `skills/` is the source of truth
- `.cursor/skills/` can consume copies of the canonical skill directories when Cursor integration is needed
- `skills/opencat-work/template/` contains the reference `TODO.md` and `DONE.md` templates

## Troubleshooting

Common causes of incomplete or blocked execution:

- OpenSpec CLI is missing
- the required OpenSpec skills are not installed
- retained worktrees are dirty, detached, or still parked on `trunk`
- the repository does not follow the expected idle-branch or task-branch conventions
- `TODO.md` contains only backlog items and no activated tasks
- `DONE.md` does not follow the lightweight append-only record format

Further reading:

- `references/install-claude-code.md`
- `references/compatibility-matrix.md`

