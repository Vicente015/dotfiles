#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

DIR="$HOME/dotfiles"

echo "Installing fish shell"
rpm-ostree install -A -y fish

echo "Adding flatpaks repos"
sudo flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# * optional repos
# sudo flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo;
# sudo flatpak remote-add --user --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo

echo "Installing homebrew"
ujust install-brew

echo "Installing homebrew packages bat,catimg,eza,git-delta,gh,micro,volta,pfetch,tldr,starship,glow"
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
brew install bat catimg eza git-delta gh micro volta pfetch tldr starship glow

echo "Installing Visual Studio Code via Flatpak with tools"
flatpak --noninteractive -y --system uninstall com.visualstudio.code
flatpak --noninteractive -y --user install com.visualstudio.code
flatpak --noninteractive -y --user install com.visualstudio.code.tool.fish
flatpak --noninteractive -y --user install com.visualstudio.code.tool.podman

echo "Installing deno"
curl -fsSL "https://deno.land/install.sh" | sh

echo "Installing node LTS and pnpm using volta"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
volta install node
volta install pnpm

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

echo "Installing global packages with pnpm eslint,pm2,envinfo,typescriot,trash-cli,share-cli,open-cli,antfu/ni,taze"
pnpm add -g eslint pm2 envinfo typescript trash-cli empty-trash-cli share-cli @antfu/ni taze open-cli

echo "Copying starship.toml"
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

mkdir -p ~/.config/fish/
echo "Installing PNPM autocompletion in fish"
pnpm completion fish > ~/.config/fish/completions/pnpm.fish

echo "Copying config.fish"
if test -f "$HOME/.config/fish/config.fish"; then
  mv ~/.config/fish/config.fish ~/.config/fish/config.fish.backup
fi
ln -s "$DIR/config.fish" ~/.config/fish/config.fish

# * Optional: Create customs dirs
# echo "Creating custom dirs"
# mkdir $HOME/i $HOME/ii $HOME/v $HOME/temp

# * Optional: Install flatpak apps
# echo "Intalling flatpak apps"
# ./sync-flatpak.sh --import-apps

# Make Fish the defualt shell
chsh -s $(which fish)
echo "Done! Everything installed"
fish

glow README_atomic_ES.md --pager
