# User-local binaries (fastfetch, eza, bat, fd, delta, btop, duf, zoxide, nvim, fzf)
typeset -U path PATH
path=("$HOME/.local/bin" $path)
export PATH
