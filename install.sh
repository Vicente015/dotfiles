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

echo "Installing node LTS and pnpm"
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm env use --global lts

echo "Installing global npm packages (tldr, eslint, pm2, envinfo, typescript, tash-cli, empty-trash-cli, share-cli) with pnpm"
pnpm add -g tldr eslint pm2 envinfo typescript trash-cli empty-trash-cli share-cli

echo "Installing GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update -y && sudo apt install gh -y

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

# PNPM Autocompletion - Yep, I don't like this but is the only way :( https://github.com/ohmyzsh/ohmyzsh/pull/9793
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pnpm && wget https://raw.githubusercontent.com/loynoir/ohmyzsh/master/plugins/pnpm/pnpm.plugin.zsh -P ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pnpm

echo "Copying .zshrc"
if test -f "$HOME/.zshrc"; then
  mv ~/.zshrc ~/zshrc.backup
fi
ln -s "$DIR/zshrc" ~/.zshrc

# Make zsh the defualt shell
chsh -s $(which zsh)
echo "Done! Everything installed"
zsh
