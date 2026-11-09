#!/usr/bin/env bash
# Home screen theme, changeable any time without rebuilding the launcher.
#   mytv/theme.sh              Aurora
#   mytv/theme.sh cinematic    any folder name under themes/
#   mytv/theme.sh --reset      back to plain black
set -euo pipefail
IP=""; NAME=aurora
for a in "$@"; do case "$a" in [0-9]*.*) IP="$a" ;; *) NAME="$a" ;; esac; done
source "$(dirname "$0")/_env.sh" "$IP"
if [ "$NAME" = --reset ]; then
  bash tools/theme.sh --reset
else
  [ -f "themes/$NAME/config.json" ] || { echo "Nao existe tema '$NAME'. Opcoes: $(ls themes | grep -v '\.md$' | tr '\n' ' ')" >&2; exit 2; }
  bash tools/theme.sh "themes/$NAME"
fi
tv --screenshot "mytv/shots/7-tema-$NAME.png" HOME --wait 3
echo "Pronto! Foto: mytv/shots/7-tema-$NAME.png"
