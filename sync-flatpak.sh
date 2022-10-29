#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

function export_apps() {
  flatpak list --app --columns=application > ./flatpak/apps.txt
}

function install_apps() {
  flatpak install -y $(grep "^[^#;]" ./flatpak/apps.txt | tr '\n' ' ')
}

function export_overrides() {
  cp -r $HOME/.local/share/flatpak/overrides/ ./flatpak/overrides/
}

function import_overrides() {
  cp -r ./flatpak/overrides/ $HOME/.local/share/flatpak/overrides/
}

case "$1" in
  "--export-overrides")
    export_overrides
    echo "Flatpak overrides exported"
  ;;
  "--import-overrides")
    import_overrides
    echo "Flatpak overrides imported"

  ;;
  "--export-apps")
    export_apps
    echo "Flatpak apps exported"
  ;;
  "--import-apps")
    import_apps
    echo "Flatpak apps imported"
  ;;
esac
