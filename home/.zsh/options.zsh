# ============================================================================
#  Shell options, history, and completion styling
# ============================================================================

# ---- History (your settings, with a bigger buffer) -------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
HISTDUP=erase

setopt append_history          # append rather than overwrite
setopt inc_append_history      # write as commands run, not at exit
setopt share_history           # share history live between sessions
setopt hist_ignore_space       # a leading space keeps a command out of history
setopt hist_ignore_dups        # don't record an immediately repeated command
setopt hist_ignore_all_dups    # remove older duplicates entirely
setopt hist_save_no_dups       # don't write duplicates to the history file
setopt hist_find_no_dups       # don't show duplicates when searching
setopt hist_reduce_blanks      # tidy up whitespace before saving
setopt hist_verify             # expand !! to the line instead of running it
setopt extended_history        # record timestamp and duration

# ---- Directory navigation ---------------------------------------------------
setopt auto_cd                 # type a directory name to cd into it
setopt auto_pushd              # every cd pushes onto the directory stack
setopt pushd_ignore_dups
setopt pushd_silent
DIRSTACKSIZE=20

# ---- Globbing & expansion ---------------------------------------------------
setopt extended_glob           # ^ ~ # in globs
setopt glob_dots               # globs match dotfiles
setopt no_case_glob            # case-insensitive globbing
setopt numeric_glob_sort       # file10 sorts after file9
setopt no_nomatch              # pass through unmatched globs (e.g. for scp)

# ---- Correction & interaction ----------------------------------------------
setopt interactive_comments    # allow # comments at the prompt
setopt no_beep                 # stop the bell
setopt prompt_subst
setopt long_list_jobs
unsetopt flow_control          # free up Ctrl+S / Ctrl+Q

# ---- Completion system ------------------------------------------------------
zmodload -i zsh/complist

# Case-insensitive, then partial-word, then substring matching (your original,
# extended with two extra fallback passes).
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no                 # fzf-tab replaces the menu
zstyle ':completion:*' verbose true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' rehash true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true

# Catppuccin-tinted completion group headers and messages
zstyle ':completion:*:*:*:*:descriptions' format '%F{147}── %d ──%f'
zstyle ':completion:*:*:*:*:corrections'  format '%F{223}── %d (errors: %e) ──%f'
zstyle ':completion:*:messages'           format '%F{117}── %d ──%f'
zstyle ':completion:*:warnings'           format '%F{211}── no matches ──%f'

# Nicer process completion for kill/killall
zstyle ':completion:*:*:kill:*:processes' \
  list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' \
  command "ps -u $USER -o pid,user,comm -w -w"

# Don't offer things that make no sense
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
