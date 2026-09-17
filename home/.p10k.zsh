# ============================================================================
#  Powerlevel10k — Catppuccin Mocha "Rainbow"
#  Hand-tuned config. Mode: nerdfont-v3 + powerline, 2 lines, transient prompt.
#  Requires a Nerd Font in the terminal (MesloLGS NF recommended).
#  Palette reference: https://github.com/catppuccin/catppuccin
# ============================================================================

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # ==========================================================================
  #  Catppuccin Mocha palette (256-colour approximations)
  # ==========================================================================
  # Saturated end of the Catppuccin range — the washed-out pastels read as
  # grey once they're used as segment backgrounds.
  local ctp_crust=233     ctp_mantle=234    ctp_base=235
  local ctp_surface0=237  ctp_surface1=238  ctp_surface2=240
  local ctp_overlay0=242  ctp_overlay1=244  ctp_subtext=145
  local ctp_text=189      ctp_lavender=147  ctp_blue=111
  local ctp_sapphire=74   ctp_sky=117       ctp_teal=80
  local ctp_green=114     ctp_yellow=222    ctp_peach=216
  local ctp_maroon=210    ctp_red=211       ctp_mauve=177
  local ctp_pink=212      ctp_flamingo=224

  # ==========================================================================
  #  Segments
  # ==========================================================================
  # Everything lives on the left. The right prompt is deliberately empty.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # distro logo
    context                 # user@host
    dir                     # current directory
    vcs                     # git status
    virtualenv              # python venv        ) only appear when
    pyenv                   # python version     ) they're actually
    nodeenv                 # node env           ) relevant, so line 1
    node_version            # node version       ) stays short
    status                  # exit code (only on failure)
    command_execution_time  # how long it took (only if >2s)
    background_jobs         # running jobs
    newline                 # ── line 2 ──
    time                    # clock — fixed position, so it never jumps
    prompt_char             # the ❯
  )

  # Nothing on the right. To put the clock back over there, move `time` out of
  # the list above and into this one.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # ==========================================================================
  #  Global look & feel
  # ==========================================================================
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate
  typeset -g POWERLEVEL9K_BACKGROUND=$ctp_surface0
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=' '
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER}'

  # Powerline separators / caps
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # Two-line prompt with a connecting frame
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  # Frame fades mauve -> lavender -> blue down the left edge
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{$ctp_mauve}╭─%f"
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX="%F{$ctp_lavender}├─%f"
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{$ctp_blue}╰─%f"
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

  # Instant prompt + transient prompt (past prompts collapse to a single ❯)
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # ==========================================================================
  #  OS icon — distro logo on mauve
  # ==========================================================================
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$ctp_mauve
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='%B${P9K_CONTENT}'

  # ==========================================================================
  #  Prompt char — ❯ green on success, red on failure
  # ==========================================================================
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$ctp_green
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$ctp_red
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # ==========================================================================
  #  Directory — blue, with truncation and a writability warning
  # ==========================================================================
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$ctp_blue
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER='…'
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=60
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$ctp_mantle
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  # Read-only / non-writable directory turns the segment red
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND=$ctp_red

  # Directories that always stay visible when the path is truncated
  local anchor_files=(
    .git .node-version .python-version .go-version .ruby-version .lua-version
    .java-version .perl-version .php-version .tool-versions .shorten_folder_marker
    package.json go.mod Cargo.toml composer.json pyproject.toml requirements.txt
    Makefile CMakeLists.txt docker-compose.yml Dockerfile
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"

  # ==========================================================================
  #  VCS / git — green clean, yellow dirty, teal untracked, red conflicts
  # ==========================================================================
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$ctp_green
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$ctp_yellow
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$ctp_teal
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$ctp_red
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$ctp_surface2
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$ctp_subtext
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

  # Branch / state icons
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
  typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_ICON=''
  typeset -g POWERLEVEL9K_VCS_COMMITS_BEHIND_ICON=''
  typeset -g POWERLEVEL9K_VCS_STASH_ICON=' '

  # ==========================================================================
  #  Status — only shown on failure (success is implied by the green ❯)
  # ==========================================================================
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND=$ctp_green
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION=''

  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=$ctp_red
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION=''

  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=$ctp_maroon
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION=''

  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_BACKGROUND=$ctp_red
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION=''

  # ==========================================================================
  #  Command execution time — peach, for anything over 2s
  # ==========================================================================
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$ctp_peach
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=''

  # ==========================================================================
  #  Background jobs
  # ==========================================================================
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=$ctp_pink
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION=''

  # ==========================================================================
  #  Context (user@host) — red for root, yellow over SSH, hidden locally
  # ==========================================================================
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=$ctp_red
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE="%B%n%f@%m"
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE{,_SUDO}_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE{,_SUDO}_BACKGROUND=$ctp_yellow
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE{,_SUDO}_TEMPLATE="%n@%m"
  # Non-root, local: sapphire instead of a drab grey
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=$ctp_sapphire
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE="%n@%m"
  # Show it always — it's a colour block on line 1, not noise
  typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''

  # ==========================================================================
  #  System load & RAM — subtle, on surface backgrounds
  # ==========================================================================
  # NOTE: load and ram are no longer in LEFT_PROMPT_ELEMENTS (they lived on the
  # old right prompt). Colours kept here so re-adding them is a one-word change.
  typeset -g POWERLEVEL9K_LOAD_WHICH=5
  typeset -g POWERLEVEL9K_LOAD_NORMAL_BACKGROUND=$ctp_surface1
  typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=$ctp_green
  typeset -g POWERLEVEL9K_LOAD_WARNING_BACKGROUND=$ctp_surface1
  typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=$ctp_yellow
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_BACKGROUND=$ctp_surface1
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=$ctp_red
  typeset -g POWERLEVEL9K_LOAD_VISUAL_IDENTIFIER_EXPANSION=''

  typeset -g POWERLEVEL9K_RAM_FOREGROUND=$ctp_sky
  typeset -g POWERLEVEL9K_RAM_BACKGROUND=$ctp_surface1
  typeset -g POWERLEVEL9K_RAM_VISUAL_IDENTIFIER_EXPANSION=''

  # ==========================================================================
  #  Language / environment segments
  # ==========================================================================
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=$ctp_teal
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION=''

  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_PYENV_BACKGROUND=$ctp_teal
  typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local)
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=false
  typeset -g POWERLEVEL9K_PYENV_VISUAL_IDENTIFIER_EXPANSION=''

  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=$ctp_green
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_NODE_VERSION_VISUAL_IDENTIFIER_EXPANSION=''

  typeset -g POWERLEVEL9K_NODEENV_FOREGROUND=$ctp_crust
  typeset -g POWERLEVEL9K_NODEENV_BACKGROUND=$ctp_green
  typeset -g POWERLEVEL9K_NODEENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_NODEENV_VISUAL_IDENTIFIER_EXPANSION=''

  # ==========================================================================
  #  Clock
  # ==========================================================================
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$ctp_lavender
  # Sits on line 2, just before the ❯: no background, so line 2 stays light
  # and the clock never shifts around the way a right-hand one does.
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_TIME_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_TIME_LEFT_LEFT_WHITESPACE=
  typeset -g POWERLEVEL9K_TIME_LEFT_RIGHT_WHITESPACE=' '

  # ==========================================================================
  #  Misc
  # ==========================================================================
  # Keep the prompt usable while gitstatus is still warming up
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0.05
  typeset -g POWERLEVEL9K_WORKER_LOG_LEVEL=

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
