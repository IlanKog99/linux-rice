#!/usr/bin/env bash
# Install the bundled Nerd Font on the Windows side (per-user, no admin). Run from WSL.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
[[ -x $PS ]] || { echo "powershell.exe not found at $PS (WSL interop disabled?)" >&2; exit 1; }

ps1_win="$(wslpath -w "$HERE/install-fonts.ps1")"
fonts_win="$(wslpath -w "$(realpath "$HERE/../fonts")")"

# Scriptblock instead of -File: execution policy only gates script *files*.
"$PS" -NoProfile -NonInteractive -Command \
  "& ([scriptblock]::Create([IO.File]::ReadAllText('$ps1_win'))) -FontDir '$fonts_win'" | tr -d '\r'
exit "${PIPESTATUS[0]}"
