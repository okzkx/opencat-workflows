---
name: opencat-task
description: Execute one OpenCat change through purpose, apply, archive, merge, and return-to-idle using an isolated git worktree and reusable idle branches.
license: MIT
version: "0.1.0"
---

# OpenCat Task

Use this skill to execute one repository change end to end.

This is the core OpenCat workflow skill. It assumes the repository has already passed `opencat-check`.

## External Dependencies

This skill does not bundle OpenSpec. For the full workflow it expects these companion skills or capabilities to exist:

- `openspec-propose`
- `openspec-apply-change`
- `openspec-archive-change`

## Required Flow

1. Determine the target change name.
2. Detect the true `trunk` branch.
3. Create or reuse a retained worktree slot.
4. Ensure the slot has a paired idle branch.
5. Switch the retained slot from its idle branch to the task branch.
6. Rebase the task branch onto the latest `trunk` before implementation.
7. Run purpose, apply, validate, archive, and merge in that order.
8. Call `opencat-cleanup` after merge so the slot returns to a reusable idle state.

## Recommended Conventions

- retained slot path: `../<repo-name>-worktree`, `../<repo-name>-worktree-2`, ...
- idle branch: `opencat/idle/<slot-name>`
- task branch: `opencat/<change-name>`

Treat these as conventions, not hard-coded assumptions. Always inspect the real repository state first.

## Rebase Rules

- rebase to latest `trunk` before implementation
- rebase again before merge
- resolve ordinary rebase and merge conflicts as part of the workflow instead of leaving the repository half-finished

## Cross-Platform Command Notes

- prefer shell syntax appropriate to the active environment
- on PowerShell, use PowerShell here-strings instead of bash heredocs
- avoid assuming `&&` is available when the shell is PowerShell

## Boundaries

- do not finish the workflow entirely inside the main worktree
- do not leave retained worktrees attached to `trunk`, detached, or dirty
- do not skip cleanup after merge
- do not assume OpenSpec artifacts are bundled with this package

## Output

Report:

- detected `trunk`
- task branch
- retained worktree path
- paired idle branch
- whether purpose/apply/archive/merge succeeded
- whether cleanup returned the slot to idle

## References

- `references/dependency-openspec.md`
- `references/workflow-stages.md`
