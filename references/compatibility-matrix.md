# Compatibility Matrix

| Target | Status | Notes |
|------|------|------|
| Claude Code directory marketplace loading | Supported | Place plugin under `custom-plugins/` root and index it in `.claude-plugin/marketplace.json` |
| Cursor skills loading | Supported | Uses `.cursor/skills/` mirror generated from canonical `skills/` |
| OpenSpec CLI | Required externally | Not bundled in this package |
| OpenSpec skills | Required for full task flow | `openspec-propose`, `openspec-apply-change`, `openspec-archive-change` |
| MCP distribution | Not included | Out of scope for first release |
| Directory marketplace packaging | Supported | Install with `claude plugin install opencat-workflows@custom-plugins` |

## Expected Repository Conventions

The target repository should ideally use:

- a detectable `trunk` branch such as `main` or `master`
- reusable `git worktree` slots
- idle branches named like `opencat/idle/<slot-name>`
- task branches named like `opencat/<change-name>`
- lightweight `TODO.md` / `DONE.md` files if `opencat-work` is used

## Common Mismatch Cases

- retained worktrees are dirty or detached
- the repo does not use a stable idle-branch convention
- package manager cannot be inferred from lockfiles
- OpenSpec is missing from `PATH` and unavailable through `npx`
- the user expects the plugin to bundle OpenSpec behavior directly
