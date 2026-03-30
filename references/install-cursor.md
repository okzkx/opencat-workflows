# Install In Cursor

## Quick Start

1. Copy `opencat-workflows/.cursor/skills/` into the target repository's `.cursor/skills/`.
2. Reopen Cursor or reload the window if the skills do not appear immediately.
3. Confirm the following skills are discoverable:
   - `opencat-check`
   - `opencat-cleanup`
   - `opencat-task`
   - `opencat-work`

## Source Of Truth

- Canonical content lives in `skills/`
- `.cursor/skills/` is only a compatibility mirror
- Update canonical files first, then run `scripts/sync-cursor-skills.ps1`

## Suggested Mirror Refresh

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-cursor-skills.ps1
```

## Notes

- Cursor compatibility in this package is intentionally file-based and lightweight.
- No MCP setup is required for the first release.
- `opencat-task` and `opencat-work` still depend on external OpenSpec capabilities.
