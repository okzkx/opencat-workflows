# Compatibility Matrix

| Target | Status | Notes |
|------|------|------|
| Claude Code directory marketplace loading | Recommended | Prefer `custom-plugins` plus `claude plugin install opencat-workflows@custom-plugins` |
| Direct Claude skills copy | Supported | Fallback path: copy canonical folders from `skills/` into `~/.claude/skills/` |
| Cursor skills loading | Supported | Copy canonical folders from `skills/` into `.cursor/skills/` when needed |
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
- the user expects Cursor-only mirror files even though canonical `skills/` is now the preferred fallback source
