# TODO And DONE Conventions

## Expected TODO.md Shape

```markdown
# TODO

## P1 >
- > Current task
- Another task

## P2
- Lower priority task

## P3
```

## Expected DONE.md Shape

```markdown
# DONE

## P1
- [2026-03-30 09:00] Current task - short result summary
```

## Interpretation Rules

- `P1 >` marks the currently focused section
- `- > Task` marks the currently focused task
- priorities are always processed as `P1`, then `P2`, then `P3`
- completed tasks are removed from `TODO.md` and appended to `DONE.md`

## Important Boundary

This workflow intentionally assumes a small, human-readable markdown queue. If a repository uses a different board format, either adapt the files first or do not use `opencat-work`.
