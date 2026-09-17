# ============================================================================
#                                  .zshrc
#  Oh My Zsh + Powerlevel10k, themed Catppuccin Mocha.
#  Personal config lives in ~/.zsh/*.zsh — edit those, not this file.
#      aliases.zsh   functions.zsh   keybinds.zsh   options.zsh   tools.zsh
# ============================================================================

# ---- Greeting ---------------------------------------------------------------
# Must stay ABOVE the instant-prompt block: anything that writes to the console
# during init has to happen before p10k takes over the screen.
if [[ -o interactive ]] && (( $+commands[fastfetch] )); then
  if [[ -z $FASTFETCH_SHOWN && -z $TMUX && -z $CLAUDECODE && $TERM != dumb ]]; then
    export FASTFETCH_SHOWN=1
    clear
    fastfetch
  fi
fi

# ---- Powerlevel10k instant prompt ------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---- Oh My Zsh --------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14

CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="%F{147}…%f"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"
ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$HOST-$ZSH_VERSION"
[[ -d $HOME/.cache/zsh ]] || mkdir -p "$HOME/.cache/zsh"

# Plugin order matters:
#   - zsh-completions must precede compinit (omz handles that via fpath)
#   - fzf-tab must load after compinit and before autosuggestions
#   - fast-syntax-highlighting must be last-ish
#   - history-substring-search must come after the highlighter
plugins=(
  git                         # 150+ git aliases and helpers
  sudo                        # press ESC twice to prepend sudo
  extract                     # `extract <any-archive>`
  colored-man-pages           # syntax-coloured man pages
  copypath                    # copy the cwd or a file path
  copyfile                    # copy a file's contents
  dirhistory                  # Alt+Left / Alt+Right through directories
  history                     # `h`, `hs` history helpers
  jsontools                   # pp_json, is_json, urlencode_json
  safe-paste                  # don't auto-run multiline pastes
  docker                      # docker completions
  systemd                     # sc-status, sc-restart, …
  zsh-completions             # extra completion definitions
  fzf-tab                     # fuzzy, previewed tab completion
  zsh-autosuggestions         # ghost-text suggestions from history
  fast-syntax-highlighting    # live command-line syntax colouring
  zsh-history-substring-search
  you-should-use              # reminds you when an alias exists
)

# Package-manager helpers, picked by what the machine actually has. Prepended so
# the ordering of the completion/highlighting plugins above is left untouched.
(( $+commands[apt-get] )) && plugins=(debian    $plugins)   # apt helpers
(( $+commands[pacman]  )) && plugins=(archlinux $plugins)   # pacman/yay helpers
(( $+commands[dnf]     )) && plugins=(dnf       $plugins)   # dnf helpers

source "$ZSH/oh-my-zsh.sh"

# ---- Personal configuration -------------------------------------------------
# tools.zsh first: it exports LS_COLORS, which options.zsh feeds to completion.
for _cfg in tools options aliases functions keybinds; do
  [[ -r "$HOME/.zsh/$_cfg.zsh" ]] && source "$HOME/.zsh/$_cfg.zsh"
done
unset _cfg

# Machine-local overrides, untracked and optional.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ---- Powerlevel10k prompt ---------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
