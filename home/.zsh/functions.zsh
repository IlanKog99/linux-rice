# ============================================================================
#  Functions
# ============================================================================

# mkcd — make a directory (with parents) and cd into it.
# Flags are passed through, and we cd into the
# last non-flag argument, so `mkcd -p a/b/c` still behaves sensibly.
mkcd() {
  local -a dirs
  local arg
  for arg in "$@"; do
    [[ $arg == -* ]] || dirs+=("$arg")
  done
  command mkdir -p -- "${(@)dirs}" || return
  (( ${#dirs} )) && builtin cd -- "${dirs[-1]}"
}

# chpwd — list the directory automatically after every cd.
chpwd() {
  emulate -L zsh
  if (( $+commands[eza] )); then
    eza --icons=auto --group-directories-first
  else
    command ls --color=auto
  fi
}

# extract — unpack basically any archive.
extract() {
  if [[ -z $1 ]]; then
    print -u2 "usage: extract <archive> [...]"
    return 1
  fi
  local f
  for f in "$@"; do
    [[ -f $f ]] || { print -u2 "extract: '$f' is not a file"; continue }
    case $f in
      *.tar.bz2|*.tbz2) tar xjf   "$f" ;;
      *.tar.gz|*.tgz)   tar xzf   "$f" ;;
      *.tar.xz|*.txz)   tar xJf   "$f" ;;
      *.tar.zst)        tar --zstd -xf "$f" ;;
      *.tar)            tar xf    "$f" ;;
      *.bz2)            bunzip2   "$f" ;;
      *.gz)             gunzip    "$f" ;;
      *.xz)             unxz      "$f" ;;
      *.zip)            unzip     "$f" ;;
      *.rar)            unrar x   "$f" ;;
      *.7z)             7z x      "$f" ;;
      *.Z)              uncompress "$f" ;;
      *) print -u2 "extract: don't know how to handle '$f'" ;;
    esac
  done
}

# mkbak — timestamped backup of a file or directory.
mkbak() {
  [[ -e $1 ]] || { print -u2 "mkbak: '$1' does not exist"; return 1 }
  local dest="${1%/}.bak-$(date +%Y%m%d-%H%M%S)"
  cp -a -- "$1" "$dest" && print "backed up -> $dest"
}

# ff — fuzzy-find a file and open it in nvim (needs fzf).
ff() {
  local file
  file=$(fdfind --type f --hidden --exclude .git 2>/dev/null | fzf \
    --preview 'batcat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}') || return
  [[ -n $file ]] && nvim -- "$file"
}

# fcd — fuzzy-find a directory and cd into it.
fcd() {
  local dir
  dir=$(fdfind --type d --hidden --exclude .git 2>/dev/null | fzf \
    --preview 'eza --tree --level=2 --icons=auto --color=always {} 2>/dev/null') || return
  [[ -n $dir ]] && builtin cd -- "$dir"
}

# psg — grep the process list.  psg nginx
psg() {
  command ps -aux | rg --color=always "$1" | rg -v "rg --color=always"
}

# serve — throwaway static HTTP server in the current directory.
serve() {
  local port="${1:-8000}"
  print "serving $PWD on http://0.0.0.0:$port"
  python3 -m http.server "$port"
}

# weather — quick forecast.  weather London
weather() { curl -s "wttr.in/${1:-}?F" }

# cheat — cheatsheet for any command.  cheat tar
cheat() { curl -s "cheat.sh/$1" }

# up — go up N directories.  up 3
up() {
  local n="${1:-1}" path=""
  repeat "$n" path+="../"
  builtin cd -- "${path:-.}"
}
