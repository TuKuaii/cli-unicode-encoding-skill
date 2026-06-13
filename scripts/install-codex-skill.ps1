param(
    [string]$Destination = (Join-Path $env:USERPROFILE '.codex\skills\cli-unicode-encoding'),
    [switch]$Force
)

Set-StrictMode -Version Latest

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')
$adapter = Join-Path $repoRoot 'adapters\codex\cli-unicode-encoding'

if ((Test-Path -LiteralPath $Destination) -and -not $Force) {
    throw "Destination already exists: $Destination. Re-run with -Force to replace it."
}

if (Test-Path -LiteralPath $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $Destination | Out-Null

Copy-Item -LiteralPath (Join-Path $adapter 'SKILL.md') -Destination (Join-Path $Destination 'SKILL.md')
Copy-Item -LiteralPath (Join-Path $adapter 'agents') -Destination (Join-Path $Destination 'agents') -Recurse
Copy-Item -LiteralPath (Join-Path $repoRoot 'AGENT_SKILL.md') -Destination (Join-Path $Destination 'AGENT_SKILL.md')
Copy-Item -LiteralPath (Join-Path $repoRoot 'references') -Destination (Join-Path $Destination 'references') -Recurse
Copy-Item -LiteralPath (Join-Path $repoRoot 'scripts') -Destination (Join-Path $Destination 'scripts') -Recurse

Write-Host "Installed cli-unicode-encoding skill to:"
Write-Host $Destination
Write-Host ""
Write-Host "Restart Codex or start a new thread so the skill list refreshes."
