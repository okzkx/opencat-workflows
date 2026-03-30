# OpenSpec Dependency

`opencat-task` integrates with OpenSpec but does not ship OpenSpec itself.

## Expected External Capabilities

- `openspec-propose`
- `openspec-apply-change`
- `openspec-archive-change`
- OpenSpec CLI available directly or through `npx openspec@latest`

## Practical Meaning

- purpose stage depends on `openspec-propose`
- apply stage depends on `openspec-apply-change`
- archive stage depends on `openspec-archive-change`

If these are missing, `opencat-task` can still explain what is required, but it should not pretend the full workflow is available.
