# Install In Claude Code

## Quick Install

1. Place `opencat-workflows/` under your local `custom-plugins` marketplace root
2. Add or verify `"source": "./opencat-workflows"` in `custom-plugins/.claude-plugin/marketplace.json`
3. Run `claude plugin install opencat-workflows@custom-plugins`
4. Open `/help` and confirm these namespaced skills are visible:
   - `/opencat-workflows:opencat-check`
   - `/opencat-workflows:opencat-cleanup`
   - `/opencat-workflows:opencat-task`
   - `/opencat-workflows:opencat-work`
   - `/opencat-workflows:opencat-agent`

This plugin-based install path is the recommended way to distribute `opencat-workflows`.

## Fallback Without Marketplace Install

1. Copy each directory under `skills/` into your local skills directory, such as `~/.claude/skills/`
2. Keep the original folder names unchanged
3. Reload Claude Code and verify the copied skills appear in `/help`

## Validate The Package

- `.claude-plugin/plugin.json` exists
- the marketplace manifest points to `./opencat-workflows`
- each skill exists at `skills/<skill-name>/SKILL.md`
- the namespaced commands appear after installation

## Reference Project

- [`fly-cat`](https://github.com/okzkx/fly-cat) documents the plugin-first setup and uses the workflow package in a real repository

## Recommended First Run

1. `/opencat-workflows:opencat-check`
2. `/opencat-workflows:opencat-cleanup` if the repo is not idle-ready
3. `/opencat-workflows:opencat-task <change-name>` or `/opencat-workflows:opencat-work`

## Notes

- This package does not bundle OpenSpec itself
- If `opencat-task` cannot find the OpenSpec skills it depends on, install those separately
- In PowerShell environments, prefer PowerShell-native command forms instead of bash heredocs
