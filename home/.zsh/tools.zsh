# ============================================================================
#  Tool integrations & theming (Catppuccin Mocha)
# ============================================================================

export PATH="$HOME/.local/bin:$PATH"

# ---- Editor / pager ---------------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-R -F -X -i -M --use-color'
export MANPAGER="sh -c 'col -bx | batcat --language man --style=plain'"
export MANROFFOPT='-c'

# ---- bat --------------------------------------------------------------------
export BAT_THEME='Catppuccin Mocha'

# ---- LS_COLORS (Catppuccin Mocha tinted) -----------------------------------
export LS_COLORS='di=1;38;5;111:ln=1;38;5;116:mh=00:pi=48;5;237;38;5;223:so=1;38;5;183:do=1;38;5;183:bd=48;5;237;38;5;216:cd=48;5;237;38;5;223:or=48;5;237;38;5;211;01:mi=1;38;5;211:su=38;5;233;48;5;211:sg=38;5;233;48;5;223:ca=00:tw=38;5;233;48;5;151:ow=38;5;111;48;5;237:st=38;5;189;48;5;111:ex=1;38;5;151:*.tar=38;5;211:*.tgz=38;5;211:*.zip=38;5;211:*.gz=38;5;211:*.bz2=38;5;211:*.xz=38;5;211:*.zst=38;5;211:*.7z=38;5;211:*.rar=38;5;211:*.deb=38;5;211:*.rpm=38;5;211:*.jpg=38;5;183:*.jpeg=38;5;183:*.png=38;5;183:*.gif=38;5;183:*.bmp=38;5;183:*.svg=38;5;183:*.webp=38;5;183:*.mp4=38;5;218:*.mkv=38;5;218:*.webm=38;5;218:*.mp3=38;5;116:*.flac=38;5;116:*.wav=38;5;116:*.ogg=38;5;116:*.pdf=38;5;210:*.md=38;5;223:*.txt=38;5;189:*.json=38;5;223:*.yml=38;5;223:*.yaml=38;5;223:*.toml=38;5;223:*.ini=38;5;223:*.conf=38;5;223:*.sh=1;38;5;151:*.zsh=1;38;5;151:*.bash=1;38;5;151:*.py=38;5;117:*.js=38;5;223:*.ts=38;5;111:*.go=38;5;116:*.rs=38;5;216:*.c=38;5;111:*.h=38;5;147:*.cpp=38;5;111:*.lua=38;5;111:*.log=38;5;242:*.bak=38;5;242:*~=38;5;242:'
export EZA_COLORS="$LS_COLORS"

# ---- fzf --------------------------------------------------------------------
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border=rounded --info=inline-right
    --prompt='  ' --pointer='▶' --marker='✓'
    --color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=selected-bg:#45475a,border:#6c7086,label:#cdd6f4
  "
  if (( $+commands[fdfind] )); then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
  fi
  export FZF_CTRL_T_OPTS="--preview 'batcat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=auto --color=always {} 2>/dev/null'"
  export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:hidden:wrap --bind='?:toggle-preview'"

  # Ctrl+T (files), Ctrl+R (history), Alt+C (cd)
  source <(fzf --zsh) 2>/dev/null
fi

# ---- fzf-tab (fuzzy, previewed tab completion) -----------------------------
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border=rounded \
  --color='bg+:#313244,fg+:#cdd6f4,hl:#f38ba8,hl+:#f38ba8,pointer:#f5e0dc,marker:#b4befe,border:#6c7086,info:#cba6f7'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' use-fzf-default-opts no
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' continuous-trigger '/'

# Directory previews (your original, upgraded from ls to eza)
zstyle ':fzf-tab:complete:cd:*'      fzf-preview 'eza -1 --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'       fzf-preview 'eza -1 --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:ls:*'      fzf-preview 'eza -1 --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:eza:*'     fzf-preview 'eza -1 --icons=auto --color=always $realpath'
# File previews for editors / viewers
zstyle ':fzf-tab:complete:(nvim|nv|vim|bat|batcat|cat|less|rcat):*' \
  fzf-preview 'batcat --style=numbers --color=always --line-range :300 $realpath 2>/dev/null || eza -1 --icons=auto --color=always $realpath'
# Environment variable previews
zstyle ':fzf-tab:complete:(export|unset|printenv):*' \
  fzf-preview 'echo ${(P)word}'
# systemctl unit previews
zstyle ':fzf-tab:complete:systemctl-*:*' \
  fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# ---- zsh-autosuggestions ----------------------------------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'      # Catppuccin overlay0
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# ---- history-substring-search ----------------------------------------------
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#45475a,fg=#a6e3a1,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#45475a,fg=#f38ba8,bold'
HISTORY_SUBSTRING_SEARCH_FUZZY=1

# ---- you-should-use (nudges you toward your own aliases) -------------------
export YSU_MESSAGE_POSITION="after"
export YSU_HARDCORE=0
export YSU_MESSAGE_FORMAT="$(print -P '%F{223}󰌶  alias found:%f %F{151}%alias%f %F{242}-> %command%f')"

# ---- zoxide (smarter cd — your original setup) -----------------------------
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"

# ---- Locale & misc ----------------------------------------------------------
# Prefer en_US.UTF-8, but only if it's actually generated: stock WSL Ubuntu ships
# just C.UTF-8, and forcing a missing locale makes perl/python/bash spam warnings.
if locale -a 2>/dev/null | command grep -qiE '^en_US\.utf-?8$'; then
  _locale=en_US.UTF-8
else
  _locale=C.UTF-8
fi
export LANG=${LANG:-$_locale}
export LC_ALL=${LC_ALL:-$_locale}
unset _locale
export COLORTERM=${COLORTERM:-truecolor}
