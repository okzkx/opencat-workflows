# Install In Claude Code

## Quick Start

1. Place `opencat-workflows/` under the local directory marketplace root, for example `plugins/marketplaces/custom-plugins/opencat-workflows/`.
2. Add or verify an entry in `custom-plugins/.claude-plugin/marketplace.json` with `"source": "./opencat-workflows"`.
3. Run `claude plugin install opencat-workflows@custom-plugins`.
4. Open `/help` and verify namespaced skills are visible:
   - `/opencat-workflows:opencat-check`
   - `/opencat-workflows:opencat-cleanup`
   - `/opencat-workflows:opencat-task`
   - `/opencat-workflows:opencat-work`

## Local Validation Checklist

1. `plugin.json` exists at `.claude-plugin/plugin.json`
2. `plugin.json` has a valid `name`
3. the marketplace manifest lists the plugin path as `./opencat-workflows`
4. each skill lives at `skills/<skill-name>/SKILL.md`
5. the namespaced skill list appears after installing the plugin

## Recommended First Run

After install, start with:

1. `/opencat-workflows:opencat-check`
2. `/opencat-workflows:opencat-cleanup` if the repository has retained worktree residue
3. `/opencat-workflows:opencat-task <change-name>` or `/opencat-workflows:opencat-work`

## Notes

- This plugin does not ship OpenSpec itself.
- If `opencat-task` cannot find the OpenSpec skills it depends on, install those separately.
- If the repo uses PowerShell, prefer PowerShell-native command forms instead of bash heredocs.
