#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

DIR="$HOME/dotfiles"


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
