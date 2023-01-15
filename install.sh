#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

DIR="$HOME/dotfiles"

echo "Configuring dnf"
sudo bash -c "echo "defaultyes=True" >> /etc/dnf/dnf.conf"
sudo bash -c "echo "keepcache=True" >> /etc/dnf/dnf.conf"
sudo bash -c "echo "countme=False" >> /etc/dnf/dnf.conf"

echo "Upgrading packages..."
# clear cache
sudo dnf clean all
sudo dnf -y --refresh update

echo "Installing rmpfusion"
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y groupupdate core

echo "Adding flatpaks repos"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo;
sudo flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo

echo "Installing curl and wget zip unzip util-linux-user"
sudo dnf -y install curl wget zip unzip util-linux-user

echo "Installing wl-clipboard"
sudo dnf install -y wl-clipboard

echo "Installing kryptor"
wget https://github.com/samuel-lucas6/Kryptor/releases/latest/download/kryptor-linux-x64.zip
unzip kryptor-linux-x64.zip -d kryptor-linux-x64
sudo cp kryptor-linux-x64/kryptor /usr/bin/kryptor
sudo chmod +x /usr/bin/kryptor
rm -r kryptor-linux-x64.zip kryptor-linux-x64/

echo "Installing developer tools"
sudo dnf -y groupinstall "Development Tools" "Development Libraries"

echo "Installing net-tools"
sudo dnf -y install net-tools

echo "Installing rclone"
sudo dnf -y install rclone

echo "Installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q --profile=default
source $HOME/.cargo/env

echo "Installing deno"
curl -fsSL https://deno.land/x/install/install.sh | sh

echo "Installing golang"
sudo dnf -y install golang

echo "Installing cli utilities (git,zsh,neofetch,pfetch)"
sudo dnf -y install git zsh neofetch
sudo wget --output-document /usr/bin/pfetch https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
sudo chmod +x /usr/bin/pfetch

# This is required to make bat work (https://github.com/sharkdp/bat/#on-ubuntu-using-apt)
# mkdir -p ~/.local/bin
# export PATH="$HOME/.local/bin:$PATH"
# ln -s /usr/bin/batcat ~/.local/bin/bat

echo "Installing other utilities with cargo (exa,delta,bat)"
cargo install exa
cargo install git-delta
cargo install --locked bat

# ? Optional // quartz setup
# echo "Installing quartz setup"
# sudo go install github.com/jackyzha0/hugo-obsidian@latest
# sudo dnf -y install hugo

echo "Installing starship"
yes | sh -c "$(curl -fsSL https://starship.rs/install.sh)"

if [ ! -d "$HOME/.oh-my-zsh" ] ; then
  echo "Installing Oh My Zsh"
  yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Installing node LTS and pnpm"
curl -fsSL https://get.pnpm.io/install.sh | sh -
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
pnpm env use --global lts

echo "Installing global npm packages with pnpm"
pnpm add -g tldr eslint pm2 envinfo typescript trash-cli empty-trash-cli share-cli @antfu/ni taze eas-cli expo-cli

echo "Installing GitHub CLI"
sudo dnf -y install gh

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

# Create customs dirs
# mkdir $HOME/i $HOME/ii $HOME/v $HOME/temp

# Install flatpak apps
# ./sync-flatpak.sh --import-apps

# Make zsh the defualt shell
chsh -s $(which zsh)
echo "Done! Everything installed"
zsh
