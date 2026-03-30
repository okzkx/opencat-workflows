---
name: opencat-cleanup
description: Clean up interrupted OpenCat task runs. Finish active OpenSpec work first, preserve unmerged task branches, and return retained worktrees to reusable idle branches.
---

# OpenCat Cleanup

Use this skill when a repository may contain interrupted OpenCat or OpenSpec work.

Its purpose is to converge the repository back to a safe, reusable state without throwing away unfinished work.

When cleanup determines that task execution must continue through `opencat-task`, prefer launching or resuming a task SubAgent instead of continuing the task directly in the parent agent.

## Core Rules

1. Finish or continue active OpenSpec changes before doing surface-level Git cleanup.
2. Never delete an unmerged task branch.
3. Return every retained worktree to a clean idle branch.
4. Preserve retained worktree directories for reuse.
5. Detect the real `trunk` branch instead of assuming a fixed name.

## States To Classify

Each retained worktree should be classified as one of:

- `idle-ready`
- `idle-dirty`
- `task-active`
- `task-dirty`
- `attached-to-trunk`
- `detached`
- `unknown-branch`

## Cleanup Policy

- If an OpenSpec change is still active, continue the change before deleting branches or resetting slots.
- If a task branch still contains commits not merged into `trunk`, continue that task through `opencat-task` in a SubAgent.
- If a task branch is already merged into `trunk`, return the paired worktree to its idle branch and delete only the stale task branch reference.
- If a retained worktree is detached, on `trunk`, or on an unknown branch, first attach it to a safe task or idle branch instead of leaving it in that state.

## Safety Boundary

Do not use destructive history-rewrite commands unless the user explicitly asks for them.

The goal is convergence, not forced cleanup.

## Output

Report:

- active OpenSpec changes still requiring follow-up
- task branches that must continue through a SubAgent running `opencat-task`
- branches that were safe to delete
- which retained worktrees are back to `idle-ready`
- whether the repository is now safe to start `opencat-work`

## References

- `references/cleanup-decision-tree.md`
