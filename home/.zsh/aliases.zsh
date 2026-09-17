# ============================================================================
#  Aliases
#  Ported from IlanKog99/ZSH_Lazy-Nvim_Backups, with modern-tool upgrades.
# ============================================================================

# ---- Your originals ---------------------------------------------------------
alias nv='nvim'
alias ..='cd ..'
alias reload='exec zsh'                  # full re-exec; cleaner than re-sourcing
alias parrot='curl -s ascii.live/parrot'
alias edit='nv ~/.zshrc'
alias cls='clear; ls'
alias python='python3'
alias py='python'
alias free='free -h'
alias rm='rm -ri'
alias df='df -h'
alias du='du -h'
alias ps='ps -aux'
alias grep='grep --color=auto'
alias neo='clear; fastfetch'
# rainbow cat, as you had it — only if lolcat is actually installed, otherwise
# `cat` would break on distros that don't ship it.
(( $+commands[lolcat] )) && alias cat='lolcat'
alias nvkeys='nv ~/.config/nvim/lua/config/keymaps.lua'

# ---- Deeper directory hops --------------------------------------------------
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# ---- ls -> eza (icons, git status, tree view) -------------------------------
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lh  --icons=auto --group-directories-first --git --time-style=long-iso'
  alias la='eza -lah --icons=auto --group-directories-first --git --time-style=long-iso'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
  alias ltt='eza --tree --level=3 --icons=auto --group-directories-first'
  alias lsize='eza -lah --icons=auto --sort=size --reverse'
  alias lnew='eza -lah --icons=auto --sort=modified --reverse'
else
  alias ls='ls --color=auto'
  alias ll='ls -lh --color=auto'
  alias la='ls -lah --color=auto'
fi

# ---- File viewing -----------------------------------------------------------
# `cat` is lolcat (above, when installed). These give syntax highlighting.
if (( $+commands[batcat] )); then
  alias bat='batcat'
  alias ccat='batcat'                    # "code cat" - highlighted, paged
  alias catp='batcat --style=plain --paging=never'
  alias bathelp='batcat --plain --language=help'
  # Colorised `--help` output:  help ls
  help() { "$@" --help 2>&1 | batcat --plain --language=help; }
fi
alias rcat='command cat'                 # the real, un-aliased cat

# ---- Disk / system ----------------------------------------------------------
(( $+commands[duf]  )) && alias dfx='duf'
(( $+commands[btop] )) && alias top='btop' && alias htop='btop'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me; echo'
alias path='echo $PATH | tr ":" "\n"'
alias now='date "+%Y-%m-%d %H:%M:%S"'

# ---- Search -----------------------------------------------------------------
(( $+commands[rg]     )) && alias rgf='rg --files | rg'
(( $+commands[fdfind] )) && alias fd='fdfind'

# ---- Git (beyond the omz git plugin) ---------------------------------------
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --graph --abbrev-commit --decorate --all \
  --format=format:"%C(bold blue)%h%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)"'

# ---- Config shortcuts -------------------------------------------------------
alias zshconf='nv ~/.zshrc'
alias zshalias='nv ~/.zsh/aliases.zsh'
alias zshfunc='nv ~/.zsh/functions.zsh'
alias zshkeys='nv ~/.zsh/keybinds.zsh'
alias p10kconf='nv ~/.p10k.zsh'
alias ffconf='nv ~/.config/fastfetch/config.jsonc'

# ---- Safety nets ------------------------------------------------------------
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
