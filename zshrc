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
source $ZSH/oh-my-zsh.sh

# Helpers
alias count_files='find . -type f | wc -l'

# has_shipped `shipped_commit` `commit`
function has_shipped() {
  if git merge-base --is-ancestor "$2" "$1"; then
    echo "Commit has shipped"
  else
    echo "Commit has not shipped"
  fi
}

# findport `port`
function findport() {
  lsof -nP -iTCP -sTCP:LISTEN | grep "$1"
}

# Replace ls
if [ "$(command -v exa)" ]; then
    unalias -m 'll'
    unalias -m 'l'
    unalias -m 'la'
    unalias -m 'ls'
    alias ls='exa -G  --color auto --icons -a -s type'
    alias ll='exa -l --color always --icons -a -s type'
fi

# Replace cat
if [ "$(command -v bat)" ]; then
  unalias -m 'cat'
  alias cat='bat -pp --theme="OneHalfDark"'
fi

eval "$(starship init zsh)"