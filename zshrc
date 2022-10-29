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

export PNPM_HOME="$HOME/.local/share/pnpm"
export DENO_INSTALL="$HOME/.deno"
export GOPATH="$HOME/.go"
export GOROOT="/usr/local/.go"
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$GOPATH/bin:$GOROOT/bin:$PNPM_HOME:$DENO_INSTALL/bin:$HOME/.local/bin:$PATH"

source $HOME/.cargo/env
source $ZSH/oh-my-zsh.sh

# Helpers
alias count_files='find . -type f | wc -l'
alias repl='NODE_PATH=$(pnpm root -g) node'
alias exifclear='flatpak run fr.romainvigier.MetadataCleaner'

# Easy access to folders
alias i='cd $HOME/i'
alias clones='cd $HOME/i/_clones'
alias forks='cd $HOME/i/_forks'
alias issues='cd $HOME/i/_issues'
alias ii='cd $HOME/ii'
alias v='cd $HOME/v'
alias tmp='cd $HOME/tmp'

# findport `port`
function findport() {
  lsof -nP -iTCP -sTCP:LISTEN | grep "$1"
}

# Replaces trash command to include clear subcommand
# https://www.npmjs.com/package/trash-cli
# https://www.npmjs.com/package/empty-trash-cli
function trash() {
  case $1 in
    --clear)
      empty-trash
      ;;
    *)
    command trash "$@";;
  esac
}

# Replace rm with a safer command
if [ "$(command -v trash)" ]; then
  unalias -m 'rm'
  alias rm='trash'
fi

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

# Wayland copy to clipboard // dnf install wl-clipboard
if [ "$(command -v wl-copy)" ]; then
  unalias -m 'cb'
  unalias -m 'pb'
  alias cb='wl-copy'
  alias pb='wl-paste'
fi

eval "$(starship init zsh)"
pfetch
