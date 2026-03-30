# Workflow Stages

## 1. Purpose

Create or update the change proposal artifacts in the main worktree.

## 2. Claim Slot

Pick a reusable retained worktree slot and verify its paired idle branch.

## 3. Apply

Move the slot into task state, rebase to latest `trunk`, and implement the change in the retained worktree.

## 4. Validate

Run the repository's relevant validation and OpenSpec validation before committing.

## 5. Archive

Generate the archive output, including a change report when appropriate.

## 6. Merge

Rebase again to latest `trunk`, then merge back to the main branch.

## 7. Return To Idle

Hand off to `opencat-cleanup` so the retained worktree returns to its clean idle branch.
