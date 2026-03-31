# Install In Cursor

## Quick Install

1. Generate the Cursor mirror from canonical `skills/`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-cursor-skills.ps1
```

2. Copy the generated `.cursor/skills/` directory into the target repository
3. Reload Cursor if the skills do not appear immediately
4. Confirm these skills are discoverable:
   - `opencat-check`
   - `opencat-cleanup`
   - `opencat-task`
   - `opencat-work`

## Source Of Truth

- canonical content lives in `skills/`
- `.cursor/skills/` is a generated compatibility mirror
- after editing canonical files, run `scripts/sync-cursor-skills.ps1` again

## Notes

- Cursor support in this package is intentionally file-based and lightweight
- no MCP setup is required for this package
- `opencat-task` and `opencat-work` still depend on external OpenSpec capabilities
