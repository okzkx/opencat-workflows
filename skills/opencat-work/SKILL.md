---
name: opencat-work
description: Execute tasks from TODO.md and DONE.md using OpenCat's serial task workflow. Always run prerequisite checks and cleanup before claiming the next task.
---

# OpenCat Work

Use this skill to process a lightweight task queue from repository files.

It is intended for repositories that prefer convention over configuration.

## Required Sequence

1. Read `TODO.md` and `DONE.md`.
2. Run `opencat-check`.
3. Run `opencat-cleanup`.
4. Only if the repository is fully idle and clean, claim the next TODO item.
5. Launch a SubAgent and execute that item through `opencat-task` inside the SubAgent.
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
- do not execute `opencat-task` directly in the parent agent; the parent agent must launch a SubAgent to run it
- the parent agent is responsible for queue selection, readiness checks, claiming, final reporting, and `TODO.md` / `DONE.md` updates
- the SubAgent is responsible for the task-level workflow inside the retained worktree, including the full `opencat-task` execution
- do not start a new task while any retained worktree is still in task state
- if a task SubAgent is already active, wait for it or resume it instead of starting a second task SubAgent
- re-verify "fix" tasks instead of assuming they are already done because of old archives

## Scope Boundary

This skill is best for simple repository queues that follow the documented `TODO.md` / `DONE.md` convention. It is not intended to adapt to arbitrary issue trackers or complex project-board schemas.

## Output

Report:

- the task selected
- its priority
- whether cleanup declared the repository ready
- whether a SubAgent was launched for `opencat-task`
- whether the task completed or failed
- what changed in `TODO.md` and `DONE.md`

## References

- `references/todo-conventions.md`
