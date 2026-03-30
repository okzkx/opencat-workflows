# OpenCat Check Prerequisites

## Required Tools

- Git
- Node.js
- the repository's preferred package manager
- OpenSpec CLI, directly or through `npx openspec@latest`

## Repository Expectations

- a detectable `trunk` branch
- permission to inspect `git worktree list --porcelain`
- lockfiles or documentation that reveal package-manager preference

## Readiness Rules

The repository is ready only when:

- the toolchain is available
- retained worktrees are not detached
- retained worktrees are not attached to `trunk`
- idle branches exist for reusable slots
- idle slots are clean

If those rules are not satisfied, hand off to `opencat-cleanup` before starting task execution.
