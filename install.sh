#!/usr/bin/env bash
# =============================================================================
#  linux-rice/install.sh — zsh + Oh My Zsh + Powerlevel10k + fastfetch + CLI
#  tools, all themed Catppuccin Mocha. See GUIDE.md.
#
#  Usage (as your normal user — NOT root, NOT sudo):
#      bash install.sh [--skip-nvim-plugins]
#
#  - Works on any glibc/musl x86_64 Linux, native or WSL2. No sudo, no package
#    manager: every tool is a static/self-contained release binary that lands in
#    ~/.local/{bin,opt}.
#  - Needs network once, to fetch vendor/ from the GitHub release (~40 MB). If
#    vendor/ is already populated it never touches the network, except for the
#    optional nvim plugin restore and p10k's gitstatusd.
#  - Idempotent: safe to re-run. Every file it replaces is backed up first to
#    ~/.rice-backup-<timestamp>/.
#  - Exits non-zero on any failure; last line is "RICE INSTALL OK" on success.
# =============================================================================
set -euo pipefail

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.rice-backup-$TS"
BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
MAN="$HOME/.local/share/man/man1"
VB="$RICE_DIR/vendor/bin"

# The tool tarballs are too big for git, so they live on a release. Override
# RICE_VENDOR_URL to point at your own fork's asset.
VENDOR_TAG="vendor-v1"
VENDOR_URL="${RICE_VENDOR_URL:-https://github.com/IlanKog99/linux-rice/releases/download/$VENDOR_TAG/vendor-bundle.tar.gz}"

SKIP_NVIM_PLUGINS=0
for arg in "$@"; do
  case $arg in
    --skip-nvim-plugins) SKIP_NVIM_PLUGINS=1 ;;
    -h|--help) sed -n '2,19p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

say()  { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1 || [[ -x /usr/games/$1 ]]; }
is_wsl() { [[ -n ${WSL_DISTRO_NAME:-} ]] || grep -qi microsoft /proc/version 2>/dev/null; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# -----------------------------------------------------------------------------
say "1/9 Preflight"
[[ $EUID -ne 0 ]] || die "run as your normal user, not root"
[[ $(uname -m) == x86_64 ]] || die "bundled binaries are x86_64 only (got $(uname -m))"

# Hard requirements: without these the installer itself cannot run.
missing=()
for cmd in zsh git curl tar gzip sha256sum find sed; do
  have "$cmd" || missing+=("$cmd")
done
if (( ${#missing[@]} )); then
  die "missing required commands: ${missing[*]}
      Debian/Ubuntu   sudo apt-get update && sudo apt-get install -y zsh git curl tar gzip coreutils findutils sed
      Fedora/RHEL     sudo dnf install -y zsh git curl tar gzip coreutils findutils sed
      Arch            sudo pacman -S --needed zsh git curl tar gzip coreutils findutils sed
      openSUSE        sudo zypper install -y zsh git curl tar gzip coreutils findutils sed
      Alpine          sudo apk add zsh git curl tar gzip coreutils findutils sed"
fi

# Soft requirements: each missing one costs exactly the one feature named here.
opt=()
have tmux   || opt+=("tmux    (tmux)                   the bundled tmux config")
have less   || opt+=("less    (less)                   \$PAGER, and git's pager")
have col    || opt+=("col     (bsdextrautils/util-linux) coloured man pages via bat")
have script || opt+=("script  (bsdutils/util-linux)    this installer's zsh self-test")
have unzip  || opt+=("unzip   (unzip)                  nvim Mason language-server downloads")
have ip     || opt+=("ip      (iproute2)               the fastfetch network row")
have lolcat || opt+=("lolcat  (lolcat)                 the rainbow 'cat' alias")
if (( ${#opt[@]} )); then
  warn "optional commands missing (package name in parentheses) — install is still safe:"
  printf '     %s\n' "${opt[@]}" >&2
fi

# Vendored tool tarballs: shipped as a release asset, fetched once.
if [[ ! -f $RICE_DIR/vendor/oh-my-zsh.tar.gz ]]; then
  say "    vendor bundle missing — downloading once (~40 MB)"
  curl -fL --retry 3 --progress-bar -o "$TMP/vendor-bundle.tar.gz" "$VENDOR_URL" \
    || die "could not download $VENDOR_URL
      With no network, copy a populated vendor/ directory next to install.sh instead."
  tar -xzf "$TMP/vendor-bundle.tar.gz" -C "$RICE_DIR" || die "vendor bundle is not a readable tar.gz"
fi

( cd "$RICE_DIR/vendor" && sha256sum --quiet -c SHA256SUMS ) || die "vendor checksum mismatch — bundle is corrupted or truncated"

# -----------------------------------------------------------------------------
say "2/9 Backing up existing files -> $BACKUP"
TARGETS=( .zshrc .zshenv .p10k.zsh .nanorc .gitconfig .tmux.conf .zsh .oh-my-zsh
          .config/fastfetch .config/bat .config/btop .config/tmux .config/nvim )
backed=0
for t in "${TARGETS[@]}"; do
  if [[ -e $HOME/$t || -L $HOME/$t ]]; then
    mkdir -p "$BACKUP/$(dirname "$t")"
    cp -a "$HOME/$t" "$BACKUP/$t"
    backed=1
  fi
done
(( backed )) || { rmdir "$BACKUP" 2>/dev/null || true; echo "    nothing to back up"; }

# -----------------------------------------------------------------------------
say "3/9 Oh My Zsh + plugins + powerlevel10k (bundled snapshot)"
rm -rf "$HOME/.oh-my-zsh"
tar -xzf "$RICE_DIR/vendor/oh-my-zsh.tar.gz" -C "$HOME"

# -----------------------------------------------------------------------------
say "4/9 Dotfiles"
# Directories are replaced wholesale so stale files can't linger.
for d in .zsh .config/fastfetch .config/bat .config/btop .config/tmux .config/nvim; do
  rm -rf "${HOME:?}/$d"
done
# Copy file-by-file with explicit modes: sources may sit on NTFS (/mnt/c), where
# every file reads as 0777, and may have picked up CRLF if edited on Windows.
while IFS= read -r -d '' src; do
  rel="${src#"$RICE_DIR/home/"}"
  [[ $rel == .gitconfig ]] && continue
  dst="$HOME/$rel"
  mkdir -p "$(dirname "$dst")"
  rm -f "$dst"
  install -m 644 "$src" "$dst"
  sed -i 's/\r$//' "$dst"
done < <(find "$RICE_DIR/home" -type f -print0)
ln -sfn "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"

# .gitconfig: copy verbatim if absent; otherwise merge key-by-key so an existing
# identity (user.name/email, credential helpers, ...) survives. Bundle wins on conflicts.
if [[ -f $HOME/.gitconfig ]]; then
  git config -f "$RICE_DIR/home/.gitconfig" --list -z |
    while IFS= read -r -d '' entry; do
      git config --global --replace-all "${entry%%$'\n'*}" "${entry#*$'\n'}"
    done
  echo "    merged into existing ~/.gitconfig"
else
  install -m 644 "$RICE_DIR/home/.gitconfig" "$HOME/.gitconfig"
  sed -i 's/\r$//' "$HOME/.gitconfig"
fi

# -----------------------------------------------------------------------------
say "5/9 CLI tools -> $BIN"
mkdir -p "$BIN" "$OPT" "$MAN"
unpack() { mkdir -p "$TMP/$1"; tar -xzf "$VB/$2" -C "$TMP/$1"; }
find_bin() { find "$TMP/$1" -type f -name "$2" -perm -u+x | head -n1; }
put_bin() {  # put_bin <unpack-dir> <binary-name>
  local f; f="$(find_bin "$1" "$2")"; [[ -n $f ]] || die "no '$2' binary in $1 tarball"
  rm -f "$BIN/$2"; install -m 755 "$f" "$BIN/$2"
}

unpack eza     eza-0.23.5-x86_64-unknown-linux-musl.tar.gz;     put_bin eza eza
unpack bat     bat-v0.26.1-x86_64-unknown-linux-musl.tar.gz;    put_bin bat bat
unpack fd      fd-v10.5.0-x86_64-unknown-linux-musl.tar.gz;     put_bin fd fd
unpack delta   delta-0.19.2-x86_64-unknown-linux-musl.tar.gz;   put_bin delta delta
unpack duf     duf_0.9.1_linux_x86_64.tar.gz;                   put_bin duf duf
unpack ripgrep ripgrep-15.2.0-x86_64-unknown-linux-musl.tar.gz; put_bin ripgrep rg
unpack fzf     fzf-0.67.0-linux_amd64.tar.gz;                   put_bin fzf fzf
unpack zoxide  zoxide-0.9.8-x86_64-unknown-linux-musl.tar.gz;   put_bin zoxide zoxide

unpack fastfetch fastfetch-2.68.1-linux-amd64.tar.gz
rm -rf "$OPT/fastfetch"; cp -a "$TMP/fastfetch/fastfetch-linux-amd64/usr" "$OPT/fastfetch"
ln -sfn "$OPT/fastfetch/bin/fastfetch" "$BIN/fastfetch"

unpack btop btop-1.4.7-x86_64-unknown-linux-musl.tar.gz
rm -rf "$OPT/btop"; cp -a "$TMP/btop/btop" "$OPT/btop"
ln -sfn "$OPT/btop/bin/btop" "$BIN/btop"

unpack nvim nvim-0.11.5-linux-x86_64.tar.gz
rm -rf "$HOME/.local/nvim-linux-x86_64"; cp -a "$TMP/nvim/nvim-linux-x86_64" "$HOME/.local/"
ln -sfn "$HOME/.local/nvim-linux-x86_64/bin/nvim" "$BIN/nvim"

# The configs call the Debian/Ubuntu package names.
ln -sfn "$BIN/bat" "$BIN/batcat"
ln -sfn "$BIN/fd"  "$BIN/fdfind"

find "$TMP/bat" "$TMP/fd" "$TMP/ripgrep" -name '*.1' -exec cp -f {} "$MAN/" \; 2>/dev/null || true

# -----------------------------------------------------------------------------
say "6/9 bat theme cache"
"$BIN/bat" cache --build >/dev/null

# -----------------------------------------------------------------------------
say "7/9 Nerd Font"
# Native Linux: the terminal reads fonts from this machine, so install them here.
# WSL: the font has to go in on the *Windows* side — see windows/install-fonts.sh.
if is_wsl; then
  echo "    WSL detected — install the font on the Windows side:"
  echo "      bash \"$RICE_DIR/windows/install-fonts.sh\""
else
  FONTDIR="$HOME/.local/share/fonts"
  mkdir -p "$FONTDIR"
  install -m 644 "$RICE_DIR"/fonts/*.ttf "$FONTDIR/"
  if have fc-cache; then
    fc-cache -f "$FONTDIR" >/dev/null 2>&1 || warn "fc-cache failed; new fonts may need a re-login"
    echo "    JetBrainsMono Nerd Font -> $FONTDIR"
  else
    warn "fontconfig (fc-cache) missing — fonts copied to $FONTDIR but not registered"
  fi
  echo "    set your terminal's font to 'JetBrainsMono Nerd Font Mono'"
fi

# -----------------------------------------------------------------------------
say "8/9 Neovim plugins"
if (( SKIP_NVIM_PLUGINS )); then
  echo "    skipped (--skip-nvim-plugins); they install on first 'nvim' launch"
elif timeout 900 "$BIN/nvim" --headless "+Lazy! restore" +qa >/dev/null 2>&1; then
  echo "    restored to lazy-lock.json"
else
  warn "nvim plugin restore failed (network?). Not fatal: plugins install on first 'nvim' launch."
fi

# -----------------------------------------------------------------------------
say "9/9 Verify"
fail=0
for t in fastfetch eza bat batcat fd fdfind delta btop duf rg fzf zoxide nvim; do
  # capture everything, then keep line 1 (piping into head would SIGPIPE multi-line
  # outputs like btop's and trip pipefail)
  if v="$("$BIN/$t" --version 2>&1)"; then
    printf '    %-9s %s\n' "$t" "$(sed 's/\x1b\[[0-9;]*m//g' <<<"${v%%$'\n'*}")"
  else
    warn "$t does not run"; fail=1
  fi
done

ff_err="$("$BIN/fastfetch" --pipe false 2>&1 >/dev/null | grep -i error || true)"
[[ -z $ff_err ]] || { warn "fastfetch config error: $ff_err"; fail=1; }

# Start a real interactive zsh on a pty; any stderr noise during startup = failure.
# `script` provides the pty. Without it the probe is skipped, not failed.
if have script; then
  probe='print -r -- "PROBE p10k=${+functions[p10k]} hss=${+widgets[history-substring-search-up]} as=${+functions[_zsh_autosuggest_start]} fzftab=${+functions[fzf-tab-complete]} mkdir=$(whence -w mkdir)"'
  zout="$(env -u CLAUDECODE -u TMUX FASTFETCH_SHOWN=1 TERM=xterm-256color \
          script -qfec "zsh -i -c '$probe'" /dev/null 2>&1 | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g; s/\r//g')"
  probe_line="$(grep '^PROBE ' <<<"$zout" || true)"
  noise="$(grep -v '^PROBE ' <<<"$zout" | grep -v '^[[:space:]]*$' || true)"
  echo "    $probe_line"
  [[ $probe_line == "PROBE p10k=1 hss=1 as=1 fzftab=1 mkdir=mkdir: command" ]] || { warn "zsh probe mismatch"; fail=1; }
  [[ -z $noise ]] || { warn "zsh printed output during startup:"; printf '%s\n' "$noise" >&2; fail=1; }
else
  warn "'script' not installed — skipped the interactive zsh self-test"
fi

if have getent; then
  login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
else
  login_shell="$(awk -F: -v u="$(id -un)" '$1==u{print $7}' /etc/passwd)"
fi
[[ $login_shell == */zsh ]] || warn "login shell is $login_shell — run:  chsh -s $(command -v zsh)"

(( fail == 0 )) || die "verification failed (see warnings above). Backup: $BACKUP"
[[ -d $BACKUP ]] && echo "    backup: $BACKUP"
echo "RICE INSTALL OK"
