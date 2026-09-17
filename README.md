<h1 align="center">Linux Rice</h1>

<p align="center">
  A complete, reproducible zsh + Neovim environment — themed Catppuccin Mocha,
  installed by one script, without sudo.
</p>

<p align="center">
  <a href="https://github.com/IlanKog99/linux-rice/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/IlanKog99/linux-rice/actions/workflows/ci.yml/badge.svg"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <img alt="Platform" src="https://img.shields.io/badge/platform-Linux%20%7C%20WSL2-1e1e2e?labelColor=cba6f7">
  <img alt="Shell" src="https://img.shields.io/badge/shell-zsh-a6e3a1">
</p>

---

## What this is

One command turns a bare shell into a finished workstation: Oh My Zsh with a
Powerlevel10k prompt, seven plugins, a fastfetch greeting, fuzzy completion, ten
modern CLI replacements, LazyVim, and tmux — every one of them themed
**Catppuccin Mocha**.

It is not a dotfiles symlink farm. Tool binaries are pinned upstream release
artifacts, plugins are pinned to commits, and Neovim plugins are pinned by
`lazy-lock.json`, so the machine you set up next month matches the one you set
up today.

|  | |
|---|---|
| **No sudo** | Everything lands in `~/.local` and `~/.config`. The only root step is installing a handful of base packages your distro may already have. |
| **No package manager** | Tools are self-contained musl/static release binaries, so the same bundle works on Ubuntu, Debian, Fedora, Arch, openSUSE. |
| **Native Linux and WSL2** | The distro logo, locale, package-manager plugins and font installation all adapt to where they run. |
| **Reversible** | Every file it overwrites is copied to `~/.rice-backup-<timestamp>/` first. |
| **Verified, not assumed** | The installer ends by running every tool, starting a real interactive zsh on a pty, and failing if anything prints a warning. CI re-runs it on four distros. |

## Quick start

```bash
git clone https://github.com/IlanKog99/linux-rice.git ~/linux-rice
bash ~/linux-rice/install.sh
```

The installer tells you if any base packages are missing and prints the exact
command for your distro. When it finishes, its last line is `RICE INSTALL OK`.

Then make zsh your login shell and open a new terminal:

```bash
chsh -s "$(command -v zsh)"
```

**On WSL2**, the Nerd Font has to be installed on the Windows side — the
installer detects WSL and skips the Linux font step:

```bash
bash ~/linux-rice/windows/install-fonts.sh      # per-user, no admin
python3 ~/linux-rice/windows/set-terminal-font.py
```

Close and reopen Windows Terminal afterwards. On native Linux, set your
terminal's font to **JetBrainsMono Nerd Font Mono** yourself.

<details>
<summary><b>Fully offline install</b></summary>

`install.sh` downloads the ~40 MB tool bundle from this repo's
[`vendor-v1` release](https://github.com/IlanKog99/linux-rice/releases/tag/vendor-v1)
once. To install on a machine with no network, extract that bundle next to
`install.sh` on a machine that does have one, then copy the whole directory over:

```bash
curl -fLO https://github.com/IlanKog99/linux-rice/releases/download/vendor-v1/vendor-bundle.tar.gz
tar -xzf vendor-bundle.tar.gz -C ~/linux-rice     # creates vendor/bin/*.tar.gz
bash ~/linux-rice/install.sh --skip-nvim-plugins  # the only other network step
```

`vendor/SHA256SUMS` is tracked in git, not in the tarball, so the download is
verified against the repo.
</details>

## What you get

**Shell** — Oh My Zsh (pinned snapshot) · Powerlevel10k two-line prompt ·
fzf-tab · zsh-autosuggestions · zsh-completions · history-substring-search ·
fast-syntax-highlighting · you-should-use · apt/pacman/dnf helpers chosen by
what the machine actually has.

**Tools** — every one pinned to an upstream release:

| | | | |
|---|---|---|---|
| [eza](https://github.com/eza-community/eza) `ls` | [bat](https://github.com/sharkdp/bat) `cat` | [fd](https://github.com/sharkdp/fd) `find` | [ripgrep](https://github.com/BurntSushi/ripgrep) `grep` |
| [delta](https://github.com/dandavison/delta) diffs | [btop](https://github.com/aristocratos/btop) `top` | [duf](https://github.com/muesli/duf) `df` | [zoxide](https://github.com/ajeetdsouza/zoxide) `cd` |
| [fzf](https://github.com/junegunn/fzf) everywhere | [fastfetch](https://github.com/fastfetch-cli/fastfetch) greeting | [neovim](https://github.com/neovim/neovim) + [LazyVim](https://www.lazyvim.org/) | [tmux](https://github.com/tmux/tmux) |

Exact versions and install paths are in [GUIDE.md §3](GUIDE.md).

**Keys** — `Ctrl+R` history · `Ctrl+T` files · `Alt+C` cd · `Ctrl+Space` accept
suggestion · `Esc Esc` prepend sudo · `Tab` fuzzy completion with previews ·
tmux prefix `Ctrl+a`.

## Layout

```
linux-rice/
├── install.sh           the installer — bash, idempotent, no sudo
├── GUIDE.md             full reference: versions, internals, pitfalls, rollback
├── home/                dotfiles, mirrored relative to $HOME
│   ├── .zshrc  .zshenv  .p10k.zsh  .nanorc  .gitconfig
│   ├── .zsh/            aliases · functions · keybinds · options · tools
│   └── .config/         fastfetch · bat · btop · tmux · nvim (LazyVim)
├── fonts/               JetBrainsMono Nerd Font
├── vendor/SHA256SUMS    checksums for the release bundle install.sh fetches
└── windows/             WSL-only: Windows font + Windows Terminal helpers
```

## Customising

Edit `~/.zsh/*.zsh`, not `~/.zshrc`. Machine-specific settings that shouldn't be
tracked go in `~/.zshrc.local`, which is sourced last if it exists.

Never run `p10k configure` — it rewrites `~/.p10k.zsh` and discards the
Catppuccin tuning. Edit that file directly instead.

To push changes back into the bundle, see [GUIDE.md §9](GUIDE.md).

## Rolling back

```bash
B=$(command ls -d ~/.rice-backup-* | tail -1)
builtin cd ~ && command rm -rf .zshrc .zshenv .p10k.zsh .nanorc .gitconfig \
  .tmux.conf .zsh .oh-my-zsh .config/{fastfetch,bat,btop,tmux,nvim}
command cp -a "$B"/. ~/
```

Tools in `~/.local/bin` and `~/.local/opt` are left alone; remove them by hand
if you want them gone. Details and caveats: [GUIDE.md §8](GUIDE.md).

## Notes for AI coding agents

[GUIDE.md](GUIDE.md) is written for you. §6 in particular lists the ways this
config changes a non-interactive tool shell — `rm -ri`, `cp -i`, `cat` as
lolcat, `cd` as zoxide, and a `chpwd` hook that lists every directory you enter.
Interactive-flag aliases can hang a tool call; use `command rm`, `builtin cd`,
or write the logic as a `bash` script, which never loads zsh aliases.

## Credits

Catppuccin Mocha palette by [catppuccin](https://github.com/catppuccin) ·
prompt by [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k) ·
Neovim distribution by [LazyVim](https://github.com/LazyVim/LazyVim) ·
font by [JetBrains](https://www.jetbrains.com/lp/mono/) patched by
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).

MIT licensed — see [LICENSE](LICENSE) for the bundled components' terms.
