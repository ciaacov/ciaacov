#!/usr/bin/env bash
# Home screen theme, changeable any time without rebuilding the launcher.
#   mytv/theme.sh              Aurora, with my 7-app dock (mytv/theme-aurora: file manager in slot 7)
#   mytv/theme.sh cinematic    any folder name under themes/
#   mytv/theme.sh --reset      back to plain black
set -euo pipefail
IP=""; NAME=aurora
for a in "$@"; do case "$a" in [0-9]*.*) IP="$a" ;; *) NAME="$a" ;; esac; done
source "$(dirname "$0")/_env.sh" "$IP"
if [ "$NAME" = --reset ]; then
  bash tools/theme.sh --reset
elif [ "$NAME" = aurora ]; then
  bash tools/theme.sh mytv/theme-aurora
else
  [ -f "themes/$NAME/config.json" ] || { echo "Nao existe tema '$NAME'. Opcoes: $(ls themes | grep -v '\.md$' | tr '\n' ' ')" >&2; exit 2; }
  bash tools/theme.sh "themes/$NAME"
fi
tv --screenshot "mytv/shots/7-tema-$NAME.png" HOME --wait 3
echo "Pronto! Foto: mytv/shots/7-tema-$NAME.png"
