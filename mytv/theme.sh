#!/usr/bin/env bash
# Home screen theme, changeable any time without rebuilding the launcher.
#   mytv/theme.sh              Aurora
#   mytv/theme.sh cinematic    any folder name under themes/
#   mytv/theme.sh --reset      back to plain black
set -euo pipefail
NAME="${1:-aurora}"
source "$(dirname "$0")/_env.sh"
if [ "$NAME" = --reset ]; then
  bash tools/theme.sh --reset
else
  [ -f "themes/$NAME/config.json" ] || { echo "Nao existe tema '$NAME'. Opcoes: $(ls themes | grep -v '\.md$' | tr '\n' ' ')" >&2; exit 2; }
  bash tools/theme.sh "themes/$NAME"
fi
tv --screenshot "mytv/shots/7-tema-$NAME.png" HOME --wait 3
echo "Pronto! Foto: mytv/shots/7-tema-$NAME.png"
