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

# echo "Installing GNOME developer libraries"
# sudo dnf -y install gtk3-devel gtk4-devel libadwaita-devel

echo "Installing Visual Studio Code via dnf repo"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf -y check-update
sudo dnf -y install code

echo "Installing docker via dnf repo"
sudo dnf -y install dnf-plugins-core
sudo dnf -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io

# echo "Installing KeeWeb"
# wget https://github.com/keeweb/keeweb/releases/download/v1.18.7/KeeWeb-1.18.7.linux.x86_64.rpm
# sudo rpm -i KeeWeb-1.18.7.linux.x86_64.rpm
# rm -r KeeWeb-1.18.7.linux.x86_64.rpm

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

echo "Installing cli utilities (git,fish,neofetch,pfetch)"
sudo dnf -y install git fish neofetch
sudo wget --output-document /usr/bin/pfetch https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
sudo chmod +x /usr/bin/pfetch

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

echo "Installing node LTS and pnpm"
curl -fsSL https://get.pnpm.io/install.sh | sh -
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
pnpm env use --global lts

echo "Installing global npm packages with pnpm"
pnpm add -g tldr eslint pm2 envinfo typescript trash-cli empty-trash-cli share-cli @antfu/ni taze eas-cli expo-cli open-cli

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

echo "Installing PNPM autocompletion in fish"
pnpm install-completion

echo "Copying config.fish"
if test -f "$HOME/.config/fish/config.fish"; then
  mv ~/.config/fish/config.fish ~/.config/fish/config.fish.backup
fi
ln -s "$DIR/config.fish" ~/.config/fish/config.fish

# Create customs dirs
# mkdir $HOME/i $HOME/ii $HOME/v $HOME/temp

# Install flatpak apps
# ./sync-flatpak.sh --import-apps

# Make Fish the defualt shell
chsh -s $(which fish)
echo "Done! Everything installed"
fish
