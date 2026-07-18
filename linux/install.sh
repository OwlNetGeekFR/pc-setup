#!/usr/bin/env sh
set -eu

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/pc-setup"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR"
cp -R "$(dirname "$0")/." "$APP_DIR/"
chmod +x "$APP_DIR/pc-setup-linux.py"

cat > "$BIN_DIR/pc-setup" <<EOF
#!/usr/bin/env sh
exec python3 "$APP_DIR/pc-setup-linux.py" "\$@"
EOF
chmod +x "$BIN_DIR/pc-setup"

cat > "$DESKTOP_DIR/pc-setup.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=PC Setup Linux Beta
Comment=Installer, mettre à jour et nettoyer Linux
Exec=$BIN_DIR/pc-setup
Icon=$APP_DIR/assets/branding/linux-tux.svg
Terminal=false
Categories=System;Utility;
StartupNotify=true
EOF

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DESKTOP_DIR" || true
printf '\nPC Setup Linux Beta est installé.\n'
printf 'Lancez-le depuis le menu des applications ou avec : %s\n' "$BIN_DIR/pc-setup"
