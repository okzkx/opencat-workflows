# Compatibility Matrix

| Target | Status | Notes |
|------|------|------|
| Claude Code directory marketplace loading | Supported | Install through `custom-plugins` and `claude plugin install opencat-workflows@custom-plugins` |
| Cursor skills loading | Supported | Uses a generated `.cursor/skills/` mirror built from canonical `skills/` |
| OpenSpec CLI | Required externally | Not bundled in this package |
| OpenSpec skills | Required for full task flow | `openspec-propose`, `openspec-apply-change`, `openspec-archive-change` |
| MCP distribution | Not included | Out of scope for this package |

## Expected Repository Conventions

The target repository should ideally have:

- a detectable `trunk` branch such as `main` or `master`
- reusable `git worktree` slots
- idle branches named like `opencat/idle/<slot-name>`
- task branches named like `opencat/<change-name>`
- lightweight `TODO.md` and `DONE.md` files when `opencat-work` is used

## Common Mismatch Cases

- retained worktrees are dirty or detached
- the repo does not use a stable idle-branch convention
- the package manager cannot be inferred from lockfiles
- OpenSpec is missing from `PATH` and unavailable through `npx`
- the user expects this package to bundle OpenSpec behavior directly
