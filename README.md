# 🪄 Dotfiles
My personal dotfiles for Fedora.
These dotfiles are compatible with any distribution using dnf as package manager.

![image](.github/readme.png)

## Usage
1. Clone this repo in your home folder, `git clone https://github.com/Vicente015/dotfiles && cd dotfiles`.
2. Modify the `name` and `email` in `gitconfig`, remove `signingkey` and `gpgsign = true` if you don't use pgp keys to sign commits.
3. Execute the install script (without sudo), `./install.sh`.
4. Enjoy :).

## Useful commands

* `gnome-extensions list --enabled > gnome-extensions.txt`: Export list of enabled GNOME extensions.
* `./sync-flatpak.sh --export-apps`: Export Flatpak apps.
* `./sync-flatpak.sh --import-apps`: Import Flatpak apps.
