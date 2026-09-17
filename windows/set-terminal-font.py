#!/usr/bin/env python3
"""Point Windows Terminal at "JetBrainsMono Nerd Font Mono" (run from WSL).

Sets profiles.defaults.font.face, and font.face on every WSL profile that
overrides it. Nothing else (color schemes etc.) is touched. A timestamped
backup of settings.json is written next to it before any change.

    python3 set-terminal-font.py              # auto-detect settings.json
    python3 set-terminal-font.py <path>       # explicit (WSL path)
    python3 set-terminal-font.py --dry-run    # show what would change
"""
import datetime, json, re, shutil, subprocess, sys
from pathlib import Path

FONT = "JetBrainsMono Nerd Font Mono"
POWERSHELL = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"


def find_settings():
    out = subprocess.run([POWERSHELL, "-NoProfile", "-Command", "$env:LOCALAPPDATA"],
                         capture_output=True, text=True, check=True).stdout.strip()
    local = Path(subprocess.run(["wslpath", "-u", out], capture_output=True, text=True,
                                check=True).stdout.strip())
    for rel in ("Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json",
                "Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json",
                "Microsoft/Windows Terminal/settings.json"):
        if (local / rel).is_file():
            return local / rel
    sys.exit(f"Windows Terminal settings.json not found under {local}. Open Windows Terminal once, then retry.")


def strip_jsonc(text):
    """Remove // and /* */ comments and trailing commas (WT allows both), respecting strings."""
    out, i, n, in_str = [], 0, len(text), False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == "\\":
                out.append(text[i + 1]); i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True; out.append(c)
        elif text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        elif text.startswith("/*", i):
            i = text.index("*/", i) + 2
            continue
        else:
            out.append(c)
        i += 1
    return re.sub(r",(\s*[}\]])", r"\1", "".join(out))


def main():
    args = [a for a in sys.argv[1:] if a != "--dry-run"]
    dry = "--dry-run" in sys.argv
    path = Path(args[0]) if args else find_settings()
    raw = path.read_text(encoding="utf-8-sig")
    data = json.loads(strip_jsonc(raw))

    changes = []
    profiles = data.setdefault("profiles", {})
    if isinstance(profiles, list):  # very old schema: profiles is a bare list
        profiles = data["profiles"] = {"list": profiles}
    font = profiles.setdefault("defaults", {}).setdefault("font", {})
    if font.get("face") != FONT:
        changes.append(f"profiles.defaults.font.face: {font.get('face')!r} -> {FONT!r}")
        font["face"] = FONT
    for p in profiles.get("list", []):
        is_wsl = p.get("source") in ("Microsoft.WSL", "Windows.Terminal.Wsl") or "wsl" in str(p.get("commandline", "")).lower()
        face = p.get("font", {}).get("face") or p.get("fontFace")
        if is_wsl and face and face != FONT:
            changes.append(f"profile {p.get('name')!r} font.face: {face!r} -> {FONT!r}")
            p.pop("fontFace", None)
            p.setdefault("font", {})["face"] = FONT

    print(f"settings: {path}")
    if not changes:
        print("already set, nothing to do")
        return
    print("\n".join("  " + c for c in changes))
    if dry:
        print("(dry run, not written)")
        return
    backup = path.with_name(f"settings.json.bak-{datetime.datetime.now():%Y%m%d-%H%M%S}")
    shutil.copy2(path, backup)
    if strip_jsonc(raw) != raw:
        print("  note: comments/trailing commas in the original were not preserved (see backup)")
    path.write_text(json.dumps(data, indent=4, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"written; backup: {backup}")


if __name__ == "__main__":
    main()
