#!/usr/bin/env bash
# Home screen theme, changeable any time without rebuilding the launcher.
#   mytv/theme.sh              Aurora (northern-lights wallpaper)
#   mytv/theme.sh cinematic    any folder name under themes/
#   mytv/theme.sh --reset      back to the plain black built-in look
# Themes only change the look: your 7-app dock and its order stay as they are.
set -euo pipefail
cd "$(dirname "$0")/.."
export TV_HOST="${TV_HOST:-192.168.1.51}"
mkdir -p mytv/shots
[ -x tools/venv/bin/python ] || { python3 -m venv tools/venv && tools/venv/bin/pip install -q -r tools/requirements.txt; }
NAME="${1:-aurora}"
if [ "$NAME" = --reset ]; then
  tools/theme.sh --reset
else
  [ -f "themes/$NAME/config.json" ] || { echo "No theme called '$NAME'. Pick one of: $(ls themes | grep -v '\.md$' | tr '\n' ' ')" >&2; exit 2; }
  tools/theme.sh "themes/$NAME"
fi
tools/venv/bin/python -I tools/tv.py --screenshot "mytv/shots/theme-$NAME.png" HOME --wait 3
echo "Screenshot: mytv/shots/theme-$NAME.png"
