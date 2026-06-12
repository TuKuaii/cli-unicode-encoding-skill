Set-StrictMode -Version Latest

Write-Host "Applying session-local UTF-8 settings. No profile, registry, Git, or user environment changes will be made."

chcp 65001 | Out-Null
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

Write-Host "Current session encodings:"
Write-Host "InputEncoding:  $([Console]::InputEncoding.WebName)"
Write-Host "OutputEncoding: $([Console]::OutputEncoding.WebName)"
Write-Host "PipeEncoding:   $($OutputEncoding.WebName)"
$sampleCodePoints = @(0x0055,0x006E,0x0069,0x0063,0x006F,0x0064,0x0065,0x0020,0x0074,0x0065,0x0073,0x0074,0x003A,0x0020,0x4E2D,0x6587,0x0020,0x0063,0x0061,0x0066,0x00E9,0x0020,0x0440,0x0443,0x0441,0x0441,0x043A,0x0438,0x0439,0x0020,0x0639,0x0631,0x0628,0x0649,0x0020,0x1F600)
$sample = -join ($sampleCodePoints | ForEach-Object { [char]::ConvertFromUtf32($_) })
Write-Host "Sample: $sample"
Write-Host ""
Write-Host "Re-run the failing command in this same session. Persist settings only if this session-local change fixes it."
