#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$ROOT/PC Setup macOS Beta.app" ]; then
  "$ROOT/build-macos-app.sh"
fi
rm -rf "$HOME/Applications/PC Setup macOS Beta.app"
mkdir -p "$HOME/Applications"
cp -R "$ROOT/PC Setup macOS Beta.app" "$HOME/Applications/"
open "$HOME/Applications/PC Setup macOS Beta.app"
