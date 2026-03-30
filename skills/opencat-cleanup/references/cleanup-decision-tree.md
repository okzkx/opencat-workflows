# Cleanup Decision Tree

## 1. Are there active OpenSpec changes?

- Yes -> continue or archive them before branch cleanup
- No -> continue to Git residue classification

## 2. Does a task branch contain commits not in `trunk`?

- Yes -> continue the task through `opencat-task`
- No -> it is safe to clean stale residue

## 3. What state is the retained worktree in?

- `idle-ready` -> keep as-is
- `idle-dirty` -> commit or otherwise preserve changes, then re-evaluate
- `task-active` -> continue task
- `task-dirty` -> preserve changes, then continue task
- `attached-to-trunk` -> move off `trunk` and restore idle or task ownership
- `detached` -> attach to a safe branch before continuing
- `unknown-branch` -> classify safely, then restore ownership

## 4. When may a task branch be deleted?

Only when:

- its relevant work is already merged into `trunk`
- the paired worktree no longer depends on it
- the worktree has been returned to its idle branch
