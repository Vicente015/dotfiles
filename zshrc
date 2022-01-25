# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zsh-autocomplete
)
skip_global_compinit=1
export WIN_HOME="/mnt/c/Users/vicen"
export WIN_DESKTOP="/mnt/d/Desktop"
export PNPM_HOME="/home/vicente/.local/share/pnpm"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PNPM_HOME:$PATH"

source $HOME/.cargo/env
source $ZSH/oh-my-zsh.sh

# Helpers
alias count_files='find . -type f | wc -l'

# findport `port`
function findport() {
  lsof -nP -iTCP -sTCP:LISTEN | grep "$1"
}

# Replaces trash command to include clear subcommand
function trash() {
  case $1 in
    --clear)
      empty-trash
      ;;
    *)
    command trash "$@";;
  esac
}

function npmrjs() {
  cd /mnt/c/Users/vicen/AppData/Roaming/runjs && npm i $1
}

# Replace ls
if [ "$(command -v exa)" ]; then
    unalias -m 'll'
    unalias -m 'l'
    unalias -m 'la'
    unalias -m 'ls'
    alias ls='exa -G --color auto --icons -s type'
    alias ll='exa -l --color always --icons -a -s type'
fi

# Replace cat
if [ "$(command -v bat)" ]; then
  unalias -m 'cat'
  alias cat='bat -pp --theme="OneHalfDark"'
fi

# Replace rm with a safer command
if [ "$(command -v trash)" ]; then
  unalias -m 'rm'
  alias rm='trash'
fi

eval "$(starship init zsh)"
neofetch
