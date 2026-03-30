# Install In Claude Code

## Quick Start

1. Clone or copy `opencat-workflows/` to a stable local path.
2. Run `claude --plugin-dir <path-to-opencat-workflows>`.
3. Open `/help` and verify namespaced skills are visible:
   - `/opencat-workflows:opencat-check`
   - `/opencat-workflows:opencat-cleanup`
   - `/opencat-workflows:opencat-task`
   - `/opencat-workflows:opencat-work`

## Local Validation Checklist

1. `plugin.json` exists at `.claude-plugin/plugin.json`
2. `plugin.json` has a valid `name`
3. each skill lives at `skills/<skill-name>/SKILL.md`
4. the namespaced skill list appears after loading the plugin

## Recommended First Run

After install, start with:

1. `/opencat-workflows:opencat-check`
2. `/opencat-workflows:opencat-cleanup` if the repository has retained worktree residue
3. `/opencat-workflows:opencat-task <change-name>` or `/opencat-workflows:opencat-work`

## Notes

- This plugin does not ship OpenSpec itself.
- If `opencat-task` cannot find the OpenSpec skills it depends on, install those separately.
- If the repo uses PowerShell, prefer PowerShell-native command forms instead of bash heredocs.
