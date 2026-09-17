# Linux Rice — reference guide

**Audience:** AI coding agents (and humans) reproducing or maintaining this
setup. [README.md](README.md) is the short version; this file is the reference.

**End state:** zsh with Oh My Zsh and a Powerlevel10k prompt, 7 plugins, a
fastfetch greeting, fzf everywhere, modern CLI replacements (eza, bat, fd, rg,
delta, btop, duf, zoxide), LazyVim, and tmux. Everything uses **Catppuccin
Mocha**.

Originally built for a Debian 13 server's root account, then adapted for WSL2
Ubuntu, then generalised to any x86_64 Linux (see §5).

---

## 0. TL;DR — run these in order

```bash
# 1. Base packages. This is the only step that needs root. install.sh checks for
#    them and prints the exact command for the running distro if any are missing.
sudo apt-get update && sudo apt-get install -y \
  zsh git curl tar gzip tmux unzip less bsdextrautils bsdutils iproute2 fontconfig lolcat

# 2. Install as the NORMAL user. Never with sudo, never as root. Safe to re-run.
git clone https://github.com/IlanKog99/linux-rice.git ~/linux-rice
bash ~/linux-rice/install.sh          # --skip-nvim-plugins to avoid that one network call
# -> the last line must be: RICE INSTALL OK

# 3. Only if the login shell isn't zsh yet (install.sh warns if so).
chsh -s "$(command -v zsh)"

# 4. WSL only — the font must be installed on the Windows side.
bash ~/linux-rice/windows/install-fonts.sh
python3 ~/linux-rice/windows/set-terminal-font.py
```

On native Linux the installer places the font itself; just point your terminal
at **JetBrainsMono Nerd Font Mono**. On WSL, close and reopen Windows Terminal.
Either way a new terminal should show the fastfetch panel, then a two-line
Catppuccin prompt.

---

## 1. Assumptions

| Item | Expected | If different |
|---|---|---|
| CPU | x86_64 | **ARM will not work**: every bundled binary is x86_64. |
| OS | Any glibc Linux, native or WSL2. CI covers Ubuntu 24.04, Debian 13, Fedora, Arch. | musl-only distros (Alpine) run the CLI tools fine but not the glibc-linked `nvim` tarball. |
| Terminal | Anything with a Nerd Font and truecolor | Without a Nerd Font the prompt and `eza` icons render as boxes. |
| User | normal user with a home directory | Don't install for root unless asked. |
| Network | Once, for the vendor bundle | Or pre-stage `vendor/` by hand, see §3. |
| WSL interop | only needed for step 4 | `appendWindowsPath=false` is fine; the scripts use full paths. |

## 2. Folder layout

```
linux-rice/
├── README.md                 the short version
├── GUIDE.md                  this file
├── install.sh                the installer (bash, idempotent, no sudo)
├── LICENSE                   MIT, plus the bundled components' terms
├── .github/workflows/ci.yml  shellcheck, zsh/lua/json syntax, real install on 4 distros
├── home/                     dotfiles, mirrored relative to $HOME
│   ├── .zshrc  .zshenv  .p10k.zsh  .nanorc  .gitconfig
│   ├── .zsh/                 aliases, functions, keybinds, options, tools (.zsh)
│   └── .config/              fastfetch/ bat/ btop/ tmux/ nvim/
├── vendor/
│   ├── SHA256SUMS            tracked in git; install.sh checks it before installing
│   ├── oh-my-zsh.tar.gz      ~/.oh-my-zsh snapshot incl. custom plugins + p10k   ┐ from the
│   └── bin/*.tar.gz          upstream GitHub release tarballs (unmodified)       ┘ release
├── fonts/                    JetBrainsMonoNerdFontMono-{Regular,Bold,Italic,BoldItalic}.ttf
└── windows/                  WSL only
    ├── install-fonts.sh      wrapper, run from WSL
    ├── install-fonts.ps1     per-user font install and registry entries
    └── set-terminal-font.py  sets the Windows Terminal font face (makes a backup first)
```

## 3. What gets installed where

`vendor/*.tar.gz` and `vendor/bin/` are **not** in git — they are ~40 MB and
would grow the history on every tool bump. They ship as `vendor-bundle.tar.gz`
on the [`vendor-v1` release](https://github.com/IlanKog99/linux-rice/releases/tag/vendor-v1).
`install.sh` downloads it when `vendor/oh-my-zsh.tar.gz` is absent, then verifies
everything against the tracked `vendor/SHA256SUMS`. Point `RICE_VENDOR_URL` at
another asset to use a fork's bundle.

| Component | Version | Upstream | Installed to |
|---|---|---|---|
| Oh My Zsh | commit `0ee67f0` | github.com/ohmyzsh/ohmyzsh | `~/.oh-my-zsh` |
| powerlevel10k (OMZ theme) | `d05a1b0` | github.com/romkatv/powerlevel10k | `~/.oh-my-zsh/custom/themes/powerlevel10k` |
| fzf-tab | `24105b1` | github.com/Aloxaf/fzf-tab | `~/.oh-my-zsh/custom/plugins/` |
| zsh-autosuggestions | `85919cd` | github.com/zsh-users/zsh-autosuggestions | 〃 |
| zsh-completions | `de02bb8` | github.com/zsh-users/zsh-completions | 〃 |
| zsh-history-substring-search | `14c8d2e` | github.com/zsh-users/zsh-history-substring-search | 〃 |
| fast-syntax-highlighting | `4672ad5` | github.com/zdharma-continuum/fast-syntax-highlighting | 〃 |
| you-should-use | `5f3d129` | github.com/MichaelAquilina/zsh-you-should-use | 〃 |
| fastfetch | 2.68.1 | github.com/fastfetch-cli/fastfetch | `~/.local/opt/fastfetch` → symlink `~/.local/bin/fastfetch` |
| btop | 1.4.7 | github.com/aristocratos/btop | `~/.local/opt/btop` → symlink `~/.local/bin/btop` |
| neovim | 0.11.5 | github.com/neovim/neovim | `~/.local/nvim-linux-x86_64` → symlink `~/.local/bin/nvim` |
| eza | 0.23.5 | github.com/eza-community/eza | `~/.local/bin/eza` |
| bat | 0.26.1 | github.com/sharkdp/bat | `~/.local/bin/bat`, plus symlink **`batcat`** |
| fd | 10.5.0 | github.com/sharkdp/fd | `~/.local/bin/fd`, plus symlink **`fdfind`** |
| ripgrep | 15.2.0 | github.com/BurntSushi/ripgrep | `~/.local/bin/rg` |
| delta | 0.19.2 | github.com/dandavison/delta | `~/.local/bin/delta` |
| duf | 0.9.1 | github.com/muesli/duf | `~/.local/bin/duf` |
| fzf | 0.67.0 | github.com/junegunn/fzf | `~/.local/bin/fzf` |
| zoxide | 0.9.8 | github.com/ajeetdsouza/zoxide | `~/.local/bin/zoxide` |
| JetBrainsMono Nerd Font | 4 styles | github.com/ryanoasis/nerd-fonts | `~/.local/share/fonts` (native Linux) or the Windows per-user font dir (WSL) |
| LazyVim plugins | pinned by `lazy-lock.json` | (git, network) | `~/.local/share/nvim/lazy` |
| gitstatusd | chosen by p10k | (network, downloaded automatically) | `~/.cache/gitstatus` |

After the vendor bundle is in place, network is only needed for the last two
rows. Without it, nvim installs its plugins on first launch and the p10k git
segment starts working once gitstatusd can be fetched.

## 4. What `install.sh` does (manual fallback)

If the script can't run, do these by hand. The script itself is the reference.

1. **Preflight:** refuses to run as root or on non-x86_64; requires `zsh git curl
   tar gzip sha256sum find sed` and warns (without failing) about optional ones;
   downloads the vendor bundle if absent; verifies `vendor/SHA256SUMS`.
2. **Backup:** copies each of these that exists to `~/.rice-backup-<YYYYmmdd-HHMMSS>/`:
   `.zshrc .zshenv .p10k.zsh .nanorc .gitconfig .tmux.conf .zsh .oh-my-zsh
   .config/{fastfetch,bat,btop,tmux,nvim}`.
3. **Oh My Zsh:** `rm -rf ~/.oh-my-zsh`, then extract `vendor/oh-my-zsh.tar.gz` into `$HOME`.
4. **Dotfiles:**
   - Deletes `~/.zsh` and `~/.config/{fastfetch,bat,btop,tmux,nvim}` so no stale
     files remain, then installs every file under `home/` with mode 644.
   - Strips `\r` from each file.
   - Creates `~/.tmux.conf` as a symlink to `~/.config/tmux/tmux.conf`.
   - `.gitconfig`: if none exists, copies it as-is. If one exists, merges it key
     by key with `git config --global --replace-all`, so the user's `[user]`
     identity survives; the bundle wins on conflicting keys.
5. **Tools:** extracts each tarball to a temp directory and installs it as shown
   in §3, including the `batcat`/`fdfind` symlinks, and copies man pages to
   `~/.local/share/man/man1`.
6. **bat cache:** `bat cache --build`, so the `Catppuccin Mocha` theme in
   `~/.config/bat/themes` resolves.
7. **Font:** on native Linux, installs `fonts/*.ttf` to `~/.local/share/fonts`
   and runs `fc-cache -f`. On WSL it prints the Windows-side command instead.
8. **nvim plugins:** `nvim --headless "+Lazy! restore" +qa`. A failure only warns.
9. **Verify:**
   - Every tool's `--version` runs, and fastfetch reports no config errors.
   - An interactive `zsh -i` on a pty must print **nothing** during startup and
     show `p10k=1 hss=1 as=1 fzftab=1 mkdir=mkdir: command`. Skipped with a
     warning if `script` isn't installed.
   - Warns if the login shell isn't zsh.

## 5. Portability decisions (don't "fix" these)

| File | Choice | Why |
|---|---|---|
| `.config/fastfetch/config.jsonc` | logo `"type": "small"`, no `source` | fastfetch auto-detects the distro's small built-in logo, so one config covers Ubuntu, Debian, Arch, Fedora… |
| `.config/fastfetch/config-tall.jsonc` | `"type": "builtin"`, no `source` | Same, full-size art. |
| `.zshrc` | `debian`/`archlinux`/`dnf` OMZ plugins prepended only when `apt-get`/`pacman`/`dnf` exists | Loading a package manager's helpers on a distro that lacks it is dead weight. Prepending keeps the ordering of the completion/highlighting plugins intact. |
| `.zsh/aliases.zsh` | `alias cat='lolcat'` guarded by `$+commands[lolcat]` | lolcat isn't packaged everywhere; an unguarded alias would break `cat` outright. |
| `.zsh/aliases.zsh` | removed `alias mkdir='mkcd'` | It turned `mkdir -p x` into a `./-p` directory. `mkcd` is still available as a function. |
| `.zsh/tools.zsh` | `en_US.UTF-8` only if `locale -a` lists it, else `C.UTF-8` | Stock WSL Ubuntu and minimal container images ship only `C.UTF-8`. Forcing a missing locale makes perl, python and bash print warnings. |
| `.zshenv` | puts `~/.local/bin` first in `$PATH` | zsh doesn't read `~/.profile`, and the fastfetch greeting runs at the top of `.zshrc`, before `tools.zsh` sets PATH. |
| `~/.local/bin/batcat`, `fdfind` | symlinks to `bat`/`fd` | The configs call the Debian package names. |
| `install.sh` | optional deps warn instead of failing | A missing `lolcat` or `tmux` costs one feature, not the install. |

## 6. Pitfalls for AI agents

- **Your own shell loads these aliases.** Agent harnesses such as Claude Code
  start their Bash tool from the user's zsh config. Once installed, commands like
  `rm` (`rm -ri`), `cp`/`mv`/`ln` (`-i`), `cat` (lolcat, rainbow output), `ps`
  (`-aux`) and `ls` (eza) behave differently, and so does `cd` (zoxide). `chpwd`
  also auto-lists the directory after every `cd`, so output gets polluted.
  → Use `command rm`, `command cp`, `builtin cd`, etc., or write logic as a
  `bash` script, which doesn't load zsh aliases. Interactive-flag aliases (`-i`)
  can **hang** a non-interactive tool call.
- **`command -v rg` can lie.** Some agent harnesses define their own `rg`
  function. Check the real binary with `ls ~/.local/bin/rg`.
- **The greeting is skipped on purpose** when `$CLAUDECODE`, `$TMUX` or
  `$FASTFETCH_SHOWN` is set, or when `TERM=dumb`. Seeing no fastfetch output in
  your own tool shell is expected. To test it, run
  `env -u CLAUDECODE script -qc "zsh -i -c exit" /dev/null`.
- **Never run `p10k configure`.** It overwrites `~/.p10k.zsh` and loses the
  Catppuccin tuning.
- **Don't `cp -a` from `/mnt/c`.** NTFS makes every file mode 0777. Use
  `install.sh`, which sets modes explicitly.
- **CRLF:** a file edited on the Windows side may gain `\r\n` line endings, which
  breaks zsh. `.gitattributes` normalises them to LF and `install.sh` strips `\r`,
  but a manual copy does neither.
- **PowerShell `.ps1` files may be blocked** by a Group Policy `RemoteSigned`
  setting that `-ExecutionPolicy Bypass` can't override. Use
  `windows/install-fonts.sh`, which passes the script in as text, not as a file.
- **Don't delete `~/.local/share/zinit`, `~/.fzf`, `~/.config/neofetch` or a
  pre-existing nvim install without asking.** They're unused by this setup but
  belong to the user.
- **Old zsh sessions** keep the old config. Only new terminals or `exec zsh` pick
  up the new one.

## 7. Manual verification

Run inside a **new terminal** (a real interactive shell):

| Check | Expected |
|---|---|
| Startup | fastfetch panel (distro logo, OS/Up/CPU/RAM/Disk/Net rows, color dots), then the prompt |
| Prompt | Line 1: mauve distro icon, sapphire `user@host`, directory, git status. Line 2: clock, then `❯` |
| `whence -w mkdir` | `mkdir: command` (not an alias) |
| `ls` | eza with icons; directories listed first |
| `cd /tmp` | automatically lists `/tmp` |
| Type a prefix + `↑` | history substring search (matched text highlighted green) |
| `Tab` after `cd ` | fzf popup with an eza preview |
| `Ctrl+Space` | accepts the grey autosuggestion |
| `Ctrl+R` / `Ctrl+T` / `Alt+C` | fzf history / file / cd pickers |
| `Esc Esc` | prepends `sudo` |
| `git diff` in a repo | delta pager with line numbers and Catppuccin colors |
| `bat ~/.zshrc` | Catppuccin Mocha syntax highlighting |
| `btop` | Catppuccin theme |
| `tmux` | status bar at the **top**; prefix is `Ctrl+a` |
| `nvkeys` | opens nvim (Catppuccin) at `~/.config/nvim/lua/config/keymaps.lua` |
| `neo` | clears the screen and shows fastfetch |
| `perl -e 1` | no locale warning |

## 8. Rollback

```bash
B=$(command ls -d ~/.rice-backup-* | tail -1)   # pick the backup you want
builtin cd ~ && command rm -rf .zshrc .zshenv .p10k.zsh .nanorc .gitconfig .tmux.conf .zsh .oh-my-zsh .config/{fastfetch,bat,btop,tmux,nvim}
command cp -a "$B"/. ~/
```

`install.sh` only backs up files that already existed. The commands above delete
everything the installer manages, then restore whatever the backup holds, so
files that didn't exist before stay deleted. Tools in `~/.local/bin` and
`~/.local/opt` aren't removed; delete them by hand if needed.
`set-terminal-font.py` leaves `settings.json.bak-*` next to Windows Terminal's
`settings.json`.

## 9. Refreshing this bundle from a configured machine

```bash
RICE=~/linux-rice
cd ~
command cp .zshrc .zshenv .p10k.zsh .nanorc .gitconfig "$RICE/home/"
command cp .zsh/*.zsh "$RICE/home/.zsh/"
for d in fastfetch bat btop tmux nvim; do command rm -rf "$RICE/home/.config/$d"; tar -cf - -C ~/.config --exclude=.git "$d" | tar -xf - -C "$RICE/home/.config"; done
tar -czf "$RICE/vendor/oh-my-zsh.tar.gz" -C ~ --exclude=.oh-my-zsh/cache --exclude=.oh-my-zsh/log .oh-my-zsh
(builtin cd "$RICE/vendor" && sha256sum oh-my-zsh.tar.gz bin/*.tar.gz > SHA256SUMS)
```

To bump a tool: replace its tarball in `vendor/bin/`, update the filename in
step 5 of `install.sh` and the table in §3 here, regenerate `SHA256SUMS`, then
publish a new vendor release and point `VENDOR_TAG` in `install.sh` at it:

```bash
tar -czf vendor-bundle.tar.gz vendor/oh-my-zsh.tar.gz vendor/bin
gh release create vendor-v2 vendor-bundle.tar.gz --title "Vendor bundle v2" --notes "..."
```

Test with a throwaway HOME before publishing:

```bash
env -i HOME=$(mktemp -d) USER=$USER TERM=xterm-256color LANG=C.UTF-8 \
  PATH=/usr/local/bin:/usr/bin:/bin:/usr/games bash "$RICE/install.sh" --skip-nvim-plugins
```

CI runs exactly this on Ubuntu, Debian, Fedora and Arch for every push.

## 10. Optional: matching the terminal's 16 ANSI colors

The prompt and tools use truecolor, so they look right under any scheme. This
only affects the 16 ANSI colors (fastfetch dots, `ls` colors). For Windows
Terminal: back up `settings.json`, add this to its `"schemes"` array, and set
`"colorScheme": "Catppuccin Mocha"` on the profile.

```json
{ "name": "Catppuccin Mocha",
  "background": "#1E1E2E", "foreground": "#CDD6F4", "cursorColor": "#F5E0DC", "selectionBackground": "#585B70",
  "black": "#45475A", "red": "#F38BA8", "green": "#A6E3A1", "yellow": "#F9E2AF",
  "blue": "#89B4FA", "purple": "#F5C2E7", "cyan": "#94E2D5", "white": "#BAC2DE",
  "brightBlack": "#585B70", "brightRed": "#F38BA8", "brightGreen": "#A6E3A1", "brightYellow": "#F9E2AF",
  "brightBlue": "#89B4FA", "brightPurple": "#F5C2E7", "brightCyan": "#94E2D5", "brightWhite": "#A6ADC8" }
```

Most Linux terminals ship a Catppuccin Mocha scheme of their own — see
[catppuccin/catppuccin](https://github.com/catppuccin/catppuccin).
