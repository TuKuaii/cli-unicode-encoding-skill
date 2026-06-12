Set-StrictMode -Version Latest

Write-Host "CLI Unicode Encoding Diagnostics - Windows PowerShell"
Write-Host ""

Write-Host "[PowerShell]"
Write-Host "Version: $($PSVersionTable.PSVersion)"
Write-Host "Edition: $($PSVersionTable.PSEdition)"
Write-Host ""

Write-Host "[Console]"
try {
    $codePage = (cmd /c chcp) 2>$null
    Write-Host "Code page: $codePage"
} catch {
    Write-Host "Code page: unavailable"
}
Write-Host "InputEncoding:  $([Console]::InputEncoding.WebName)"
Write-Host "OutputEncoding: $([Console]::OutputEncoding.WebName)"
Write-Host "PipeEncoding:   $($OutputEncoding.WebName)"
Write-Host ""

Write-Host "[Git]"
try {
    $quotePath = git config --global --get core.quotepath 2>$null
    if ([string]::IsNullOrWhiteSpace($quotePath)) {
        $quotePath = "(unset)"
    }
    Write-Host "core.quotepath: $quotePath"
} catch {
    Write-Host "git: unavailable"
}
Write-Host ""

Write-Host "[Python]"
try {
    python -c "import sys,locale; print('stdout=' + str(sys.stdout.encoding)); print('preferred=' + str(locale.getpreferredencoding(False)))"
} catch {
    Write-Host "python: unavailable"
}
Write-Host ""

Write-Host "[Unicode smoke test]"
$sampleCodePoints = @(0x0055,0x006E,0x0069,0x0063,0x006F,0x0064,0x0065,0x0020,0x0074,0x0065,0x0073,0x0074,0x003A,0x0020,0x4E2D,0x6587,0x0020,0x0063,0x0061,0x0066,0x00E9,0x0020,0x0440,0x0443,0x0441,0x0441,0x043A,0x0438,0x0439,0x0020,0x0639,0x0631,0x0628,0x0649,0x0020,0x1F600)
$sample = -join ($sampleCodePoints | ForEach-Object { [char]::ConvertFromUtf32($_) })
Write-Host $sample

Write-Host ""
Write-Host "[Suggested next steps]"
Write-Host "1. If output or pipes are broken, test scripts/windows-session-utf8.ps1 in the current session."
Write-Host "2. If a specific file is garbled, try explicit file encodings before changing terminal settings."
Write-Host "3. Do not persist profile, Git, or environment changes until a temporary test fixes the exact failure."
