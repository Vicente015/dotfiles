#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Upgrading packages..."
sudo apt update -y && sudo apt upgrade -y

echo "Installing curl and wget"
sudo apt -y install curl wget

echo "Installing developer tools"
sudo apt -y install build-essential

echo "Installing net-tools"
sudo apt -y install net-tools

echo "Installing latest rust"
echo "1" | sh -c "$(curl https://sh.rustup.rs -sSf)"
source $HOME/.cargo/env

echo "Installing utilities (git,zsh,bat,neofetch)"
sudo apt -y install git
sudo apt -y install zsh
sudo apt -y install bat
sudo apt -y install neofetch

# This is required to make bat work (https://github.com/sharkdp/bat/#on-ubuntu-using-apt)
mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
ln -s /usr/bin/batcat ~/.local/bin/bat

echo "Installing other utilities with cargo (exa,delta)"
cargo install exa
cargo install git-delta

echo "Installing starship"
yes | sh -c "$(curl -fsSL https://starship.rs/install.sh)"

if [ ! -d "$HOME/.oh-my-zsh" ] ; then
  echo "Installing Oh My Zsh"
  yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Installing node LTS"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install --lts
nvm use --lts
npm install -g npm@^8

echo "Installing global npm packages (tldr,eslint,pm2,env-info,typescript)"
npm install -g tldr eslint pm2 env-info typescript

echo "Installing GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update -y && sudo apt install gh -y

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Installing nerd font"
curl -fLo "FiraCodeNerdFont.ttf" \
https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
mkdir -p ~/.local/share/fonts
mv FiraCodeNerdFont.ttf ~/.local/share/fonts/FiraCodeNerdFont.ttf

echo "Configuring Starship"
mkdir -p ~/.config &&
if test -f "$HOME/.config/starship.toml"; then
  mv ~/.config/starship.toml ~/.config/starship.toml.backup
fi
ln -s "$DIR/starship.toml" ~/.config/starship.toml

echo "Copying .gitconfig"
if test -f "$HOME/.gitconfig"; then
  mv ~/.gitconfig ~/gitconfig.backup
fi
ln -s "$DIR/gitconfig" ~/.gitconfig

echo "Installing oh-my-zsh plugins (autosuggestions,syntax-highlighting,completions,history-substring-search,autocomplete)"
# Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# History substring search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# Autocomplete
git clone https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

echo "Copying .zshrc"
if test -f "$HOME/.zshrc"; then
  mv ~/.zshrc ~/zshrc.backup
fi
ln -s "$DIR/zshrc" ~/.zshrc

# Make zsh the defualt shell
chsh -s $(which zsh)
echo "Done! Everything installed"
zsh