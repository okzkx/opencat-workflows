param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$skillRoot = Join-Path $Root "skills"
$cursorRoot = Join-Path $Root ".cursor\skills"

if (-not (Test-Path $skillRoot)) {
    throw "Canonical skills directory not found: $skillRoot"
}

New-Item -ItemType Directory -Force -Path $cursorRoot | Out-Null

$copied = @()

Get-ChildItem -Path $skillRoot -Directory | Sort-Object Name | ForEach-Object {
    $sourceSkill = Join-Path $_.FullName "SKILL.md"
    if (-not (Test-Path $sourceSkill)) {
        return
    }

    $targetDir = Join-Path $cursorRoot $_.Name
    $targetSkill = Join-Path $targetDir "SKILL.md"

    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -Path $sourceSkill -Destination $targetSkill -Force
    $copied += $targetSkill
}

Write-Host "Synced $($copied.Count) skill(s) to $cursorRoot"
foreach ($path in $copied) {
    Write-Host " - $path"
}
