---
name: opencat-check
description: Prepare OpenCat and OpenSpec prerequisites before repository task execution. Validate Git, Node.js, the preferred package manager, OpenSpec, and reusable worktree slots.
---

# OpenCat Check

Use this skill before `opencat-task` or `opencat-work`.

Its job is to determine whether a repository is safe and ready for OpenCat-style execution.

When this skill is used as part of `opencat-work`, it normally runs in the parent agent before any task SubAgent is launched.

## What This Skill Must Validate

1. The target path is the intended Git repository.
2. The real `trunk` branch can be detected, usually `main` or `master`.
3. `git` is available.
4. `node` is available.
5. The repository's preferred package manager can be inferred from lockfiles and is available.
6. OpenSpec is available either directly or through `npx openspec@latest`.
7. Reusable worktree slots obey the idle-branch / task-branch convention.

## Preferred Package Manager Detection

Infer the package manager from repository files instead of hard-coding one:

- `pnpm-lock.yaml` -> `pnpm`
- `yarn.lock` -> `yarn`
- `package-lock.json` -> `npm`
- otherwise fall back to the repository's documented default, if one exists

## Worktree Safety Rules

Never treat a retained worktree as reusable if it is:

- detached
- directly attached to `trunk`
- dirty while on its idle branch
- attached to an unknown branch that cannot be explained as a task branch

Recommended conventions:

- idle branch: `opencat/idle/<slot-name>`
- task branch: `opencat/<change-name>`

## Safe Fixes This Skill May Apply

This skill may perform only small, low-risk repairs:

- create the first reusable worktree slot if none exists
- create a missing idle branch for an otherwise healthy retained slot
- install or bootstrap missing prerequisites when the environment allows it

## Problems That Must Escalate

If a retained worktree is detached, dirty, attached to `trunk`, or attached to an unknown branch, stop treating the repository as ready and hand off to `opencat-cleanup`.

Do not invent destructive repair steps.

## Output

Report:

- which tools were already available
- which tools or dependencies were installed during the run
- which worktree slots are `idle-ready`
- whether `opencat-cleanup` is required before task execution
- whether the repository is ready for a SubAgent to run `opencat-task`

## References

- `references/prerequisites.md`
