Set-StrictMode -Version Latest

$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')
$errors = New-Object System.Collections.Generic.List[string]

function Assert-File {
    param([string]$RelativePath)
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $errors.Add("Missing file: $RelativePath")
    }
}

function Assert-Contains {
    param([string]$RelativePath, [string]$Pattern)
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $errors.Add("Missing file for content check: $RelativePath")
        return
    }
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ($text -notmatch $Pattern) {
        $errors.Add("Missing pattern in ${RelativePath}: $Pattern")
    }
}

function Assert-AsciiFile {
    param([string]$RelativePath)
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $errors.Add("Missing file for ASCII check: $RelativePath")
        return
    }
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes | Where-Object { $_ -gt 127 } | Select-Object -First 1) {
        $errors.Add("File is not ASCII-only: $RelativePath")
    }
}

$requiredFiles = @(
    '.gitattributes',
    'ACCEPTANCE.md',
    'AGENT_SKILL.md',
    'LICENSE',
    'README.md',
    'adapters\codex\cli-unicode-encoding\SKILL.md',
    'adapters\codex\cli-unicode-encoding\agents\openai.yaml',
    'adapters\claude-code\CLAUDE.md',
    'adapters\cursor\rules.md',
    'references\troubleshooting.md',
    'references\legacy-encodings.md',
    'scripts\diagnose-windows-powershell.ps1',
    'scripts\windows-session-utf8.ps1',
    'scripts\diagnose-posix.sh',
    'scripts\install-codex-skill.ps1',
    'scripts\check-repo.ps1'
)

foreach ($file in $requiredFiles) {
    Assert-File $file
}

Assert-Contains 'AGENT_SKILL.md' 'Use automatically before'
Assert-Contains 'AGENT_SKILL.md' 'Do not pipe inline scripts'
Assert-Contains 'AGENT_SKILL.md' 'S0 inspect-only'
Assert-Contains 'AGENT_SKILL.md' 'S3 project/data-changing'
Assert-Contains 'references\troubleshooting.md' 'Inline scripts and pipes'
Assert-Contains 'references\troubleshooting.md' 'UTF-8 argument file'
Assert-Contains 'references\troubleshooting.md' 'SSH boundary'
Assert-Contains 'references\legacy-encodings.md' 'Shift_JIS'
Assert-Contains 'adapters\codex\cli-unicode-encoding\SKILL.md' 'Automatically use before'
Assert-Contains 'README.md' 'install-codex-skill.ps1'

Assert-AsciiFile 'scripts\diagnose-windows-powershell.ps1'
Assert-AsciiFile 'scripts\windows-session-utf8.ps1'
Assert-AsciiFile 'scripts\install-codex-skill.ps1'
Assert-AsciiFile 'scripts\check-repo.ps1'

if ($errors.Count -gt 0) {
    Write-Error ($errors -join [Environment]::NewLine)
    exit 1
}

Write-Host "Repository checks passed."
