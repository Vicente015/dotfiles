#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

DIR="$HOME/dotfiles"

echo "Configuring dnf"
sudo bash -c "echo "defaultyes=True" >> /etc/dnf/dnf.conf"
sudo bash -c "echo "keepcache=True" >> /etc/dnf/dnf.conf"
sudo bash -c "echo "countme=False" >> /etc/dnf/dnf.conf"

echo "Upgrading packages..."
# ? clear cache
sudo dnf clean all
sudo dnf -y --refresh update

# ? should be easy to install with GUI
# echo "Installing rmpfusion"
# sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# sudo dnf -y groupupdate core

echo "Adding flatpaks repos"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# * optional
# sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo;
# sudo flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo

echo "Installing curl and wget zip unzip util-linux-user"
sudo dnf -y install curl wget zip unzip util-linux-user

echo "Installing wl-clipboard"
sudo dnf install -y wl-clipboard

# ? unused
# echo "Installing kryptor"
# wget https://github.com/samuel-lucas6/Kryptor/releases/latest/download/kryptor-linux-x64.zip
# unzip kryptor-linux-x64.zip -d kryptor-linux-x64
# sudo cp kryptor-linux-x64/kryptor /usr/bin/kryptor
# sudo chmod +x /usr/bin/kryptor
# rm -r kryptor-linux-x64.zip kryptor-linux-x64/

# ? very heavy
# echo "Installing developer tools"
# sudo dnf -y groupinstall "Development Tools" "Development Libraries"

# * optional
# echo "Installing GNOME developer libraries"
# sudo dnf -y install gtk3-devel gtk4-devel libadwaita-devel

echo "Installing Visual Studio Code via dnf repo"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf -y install code

# * optional -- preferred podman
# echo "Installing docker via dnf repo"
# sudo dnf -y install dnf-plugins-core
# sudo dnf -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
# sudo dnf -y install docker-ce docker-ce-cli containerd.io

# * optional
# echo "Installing net-tools"
# sudo dnf -y install net-tools
# echo "Installing rclone"
# sudo dnf -y install rclone

# * optional
# echo "Installing rust"
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q --profile=default
# source $HOME/.cargo/env

echo "Installing deno"
curl -fsSL https://deno.land/x/install/install.sh | sh

echo "Installing cli utilities (git,fish,pfetch)"
sudo dnf -y install git fish
wget --output-document ~/.local/bin/pfetch https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
chmod +x ~/.local/bin/pfetch

echo "Installing other utilities with cargo (exa)"
sudo dnf -y install exa git-delta bat

echo "Installing starship"
yes | sh -c "$(curl -fsSL https://starship.rs/install.sh)"

echo "Installing node LTS and pnpm using volta (https://volta.sh/)"
mkdir -p ~/.volta/bin
wget --output-document ~/.volta/bin/volta-1.1.1-linux.tar.gz https://github.com/volta-cli/volta/releases/download/v1.1.1/volta-1.1.1-linux.tar.gz
tar xvfz ~/.volta/bin/volta-1.1.1-linux.tar.gz && rm ~/.volta/bin/volta-1.1.1-linux.tar.gz
~/.volta/bin/volta setup
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
volta install node@20
volta install pnpm

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

echo "Installing global packages with pnpm"
pnpm add -g tldr eslint pm2 envinfo typescript trash-cli empty-trash-cli share-cli @antfu/ni taze open-cli

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

echo "Installing PNPM autocompletion in fish"
pnpm install-completion

echo "Copying config.fish"
if test -f "$HOME/.config/fish/config.fish"; then
  mv ~/.config/fish/config.fish ~/.config/fish/config.fish.backup
fi
ln -s "$DIR/config.fish" ~/.config/fish/config.fish

# * create customs dirs
# mkdir $HOME/i $HOME/ii $HOME/v $HOME/temp

# * install flatpak apps
# ./sync-flatpak.sh --import-apps

# Make Fish the defualt shell
chsh -s $(which fish)
echo "Done! Everything installed"
fish
