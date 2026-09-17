# Per-user install of the bundled JetBrainsMono Nerd Font Mono (no admin needed).
# Idempotent: files already present / already registered are skipped.
#
# Normally run via the wrapper (from WSL):   bash rice/windows/install-fonts.sh
# The wrapper exists because a GPO "RemoteSigned" policy - which
# -ExecutionPolicy Bypass cannot override - blocks unsigned .ps1 *files* on
# \\wsl.localhost paths. It feeds this file in as a scriptblock instead.
param([string]$FontDir = (Join-Path $PSScriptRoot '..\fonts'))
$ErrorActionPreference = 'Stop'

$src  = $FontDir
$dest = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$reg  = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

New-Item -ItemType Directory -Force -Path $dest | Out-Null
if (-not (Test-Path $reg)) { New-Item -Path $reg -Force | Out-Null }
$registered = @((Get-ItemProperty $reg).PSObject.Properties | ForEach-Object { "$($_.Value)" })

foreach ($f in Get-ChildItem -Path $src -Filter '*.ttf') {
    $target = Join-Path $dest $f.Name
    if (Test-Path $target) { $copied = 'present' } else { Copy-Item $f.FullName $target; $copied = 'copied' }

    if ($registered -contains $target -or $registered -contains $f.Name) {
        $regState = 'already registered'
    } else {
        New-ItemProperty -Path $reg -Name "$($f.BaseName) (TrueType)" -Value $target -PropertyType String -Force | Out-Null
        $regState = 'registered'
    }
    Write-Output ("{0,-45} file {1,-8} registry {2}" -f $f.Name, $copied, $regState)
}
Write-Output 'Fonts OK. Restart Windows Terminal if it was open.'
