# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zsh-autocomplete
  pnpm
  sudo
)
skip_global_compinit=1
export WIN_USER="vicen"
export WIN_HOME="/mnt/c/Users/$WIN_USER"
export WIN_DESKTOP="/mnt/d/Desktop"
export PNPM_HOME="/home/vicente/.local/share/pnpm"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PNPM_HOME:$PATH"
export GPG_TTY=$(tty) # This fixes gpg in WSL

source $HOME/.cargo/env
source $ZSH/oh-my-zsh.sh

# Helpers
alias count_files='find . -type f | wc -l'
alias i='cd $HOME/i'
alias clones='cd $HOME/i/_clones'
alias forks='cd $HOME/i/_forks'
alias issues='cd $HOME/i/_issues'
alias tmp='cd $HOME/tmp'

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

# npmrjs [package]
function npmrjs() {
  cd "/mnt/c/Users/$WIN_USER/AppData/Roaming/runjs" && npm i $1
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
# neofetch
