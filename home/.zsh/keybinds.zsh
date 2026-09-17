# ============================================================================
#  Key bindings
#  Emacs-style, mirroring the Ctrl+A/E/Z/arrow habits from your nvim keymaps.
# ============================================================================

bindkey -e                                    # emacs mode (your original)

# ---- Your originals ---------------------------------------------------------
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ---- Line navigation (matches your nvim Ctrl+A / Ctrl+E) --------------------
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# ---- Undo / redo (matches your nvim Ctrl+Z) --------------------------------
# Safe at the prompt: there is no running job to suspend here.
bindkey '^z' undo
bindkey '^y' redo

# ---- Ctrl + Arrow = move by word (matches your nvim Ctrl+Left/Right) -------
# Bound across the sequence variants different terminals emit, so this works
# in SecureCRT, xterm, tmux and screen alike.
for seq in '^[[1;5C' '^[[5C' '^[Oc' '^[[1;3C' '^[f'; do
  bindkey "$seq" forward-word
done
for seq in '^[[1;5D' '^[[5D' '^[Od' '^[[1;3D' '^[b'; do
  bindkey "$seq" backward-word
done
unset seq

# ---- Home / End / Delete (terminal-agnostic) -------------------------------
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word                   # Ctrl+Delete
bindkey '^H'    backward-kill-word            # Ctrl+Backspace
bindkey '^[^?'  backward-kill-word            # Alt+Backspace

# ---- History substring search on the arrow keys ----------------------------
# Type a prefix, then press Up: only matching history entries are offered.
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
fi

# ---- Autosuggestion acceptance ---------------------------------------------
bindkey '^ '  autosuggest-accept              # Ctrl+Space: accept whole hint
bindkey '^[[Z' reverse-menu-complete          # Shift+Tab: cycle backwards

# ---- Edit the current command line in nvim (Ctrl+X Ctrl+E) -----------------
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# ---- Ctrl+O: fuzzy-pick a file and insert its path -------------------------
_fzf_insert_file() {
  local file
  file=$(fdfind --type f --hidden --exclude .git 2>/dev/null | fzf --height 40%) || return
  [[ -n $file ]] && LBUFFER+="${(q)file} "
  zle reset-prompt
}
zle -N _fzf_insert_file
bindkey '^o' _fzf_insert_file

# ---- Alt+C / Ctrl+T / Ctrl+R come from fzf's key-bindings (see tools.zsh) --
