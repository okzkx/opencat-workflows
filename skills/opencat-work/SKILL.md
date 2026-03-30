---
name: opencat-work
description: Execute tasks from TODO.md and DONE.md using OpenCat's serial task workflow. Always run prerequisite checks and cleanup before claiming the next task.
license: MIT
version: "0.1.0"
---

# OpenCat Work

Use this skill to process a lightweight task queue from repository files.

It is intended for repositories that prefer convention over configuration.

## Required Sequence

1. Read `TODO.md` and `DONE.md`.
2. Run `opencat-check`.
3. Run `opencat-cleanup`.
4. Only if the repository is fully idle and clean, claim the next TODO item.
5. Execute that item through `opencat-task`.
6. Update `TODO.md` and `DONE.md`.
7. Run `opencat-check` and `opencat-cleanup` again before claiming another task.

## Selection Rules

- priority order: `P1 > P2 > P3`
- a section marked with `>` is the active section
- a task marked with `>` is the active task
- when there is no active task, choose the first task from the active section
- if there is no active section with tasks, choose the first available task by priority

## Operational Rules

- run tasks serially, never in parallel
- do not bypass `opencat-task`
- do not start a new task while any retained worktree is still in task state
- re-verify "fix" tasks instead of assuming they are already done because of old archives

## Scope Boundary

This skill is best for simple repository queues that follow the documented `TODO.md` / `DONE.md` convention. It is not intended to adapt to arbitrary issue trackers or complex project-board schemas.

## Output

Report:

- the task selected
- its priority
- whether cleanup declared the repository ready
- whether the task completed or failed
- what changed in `TODO.md` and `DONE.md`

## References

- `references/todo-conventions.md`
