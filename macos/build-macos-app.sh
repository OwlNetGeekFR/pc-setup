#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
APP="$ROOT/PC Setup macOS Beta.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

rm -rf "$APP"
mkdir -p "$MACOS" "$RESOURCES/Web/assets"

xcrun swiftc "$ROOT/PCSetupMac.swift" \
  -framework AppKit -framework WebKit \
  -o "$MACOS/PCSetupMac"

cp "$ROOT/index.html" "$ROOT/app.js" "$ROOT/styles.css" "$ROOT/macos-bridge.js" "$RESOURCES/Web/"
cp -R "$ROOT/assets/branding" "$ROOT/assets/logos" "$RESOURCES/Web/assets/"
cp "$ROOT/assets/branding/macos-apple.svg" "$RESOURCES/"

ICONSET="$ROOT/PCSetupMac.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"
if sips -s format png "$ROOT/assets/branding/macos-apple.svg" --out "$ROOT/PCSetupMac-1024.png" >/dev/null 2>&1; then
  for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$ROOT/PCSetupMac-1024.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z "$double" "$double" "$ROOT/PCSetupMac-1024.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
  done
  if ! iconutil -c icns "$ICONSET" -o "$RESOURCES/PCSetupMac.icns"; then
    printf 'Avertissement : icône ICNS non générée, l’application utilisera son icône intégrée.\n'
  fi
  rm -rf "$ICONSET" "$ROOT/PCSetupMac-1024.png"
fi

cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>PC Setup macOS Beta</string>
  <key>CFBundleDisplayName</key><string>PC Setup macOS Beta</string>
  <key>CFBundleIdentifier</key><string>fr.owlnetgeek.pcsetup.macos.beta</string>
  <key>CFBundleExecutable</key><string>PCSetupMac</string>
  <key>CFBundleIconFile</key><string>PCSetupMac</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>3.3.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

python3 - <<'PY'
from pathlib import Path
p=Path("PC Setup macOS Beta.app/Contents/Resources/Web/index.html")
s=p.read_text(encoding="utf-8")
s=s.replace('<script src="app.js"></script>','<script src="macos-bridge.js"></script>\n  <script src="app.js"></script>')
p.write_text(s,encoding="utf-8")
PY

codesign --force --deep --sign - "$APP"
printf '\nApplication créée : %s\n' "$APP"
printf 'Déplacez-la dans le dossier Applications pour la tester.\n'
