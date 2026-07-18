#!/usr/bin/env sh
set -eu
rm -f "$HOME/.local/bin/pc-setup"
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/applications/pc-setup.desktop"
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/pc-setup"
printf 'PC Setup Linux a été désinstallé.\n'
