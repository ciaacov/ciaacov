#!/usr/bin/env bash
# Undo everything: round 2, the theme, the first cleanup, Home back to Google TV, launcher removed.
#   KEEP_LAUNCHER=1 mytv/restore.sh   to leave the launcher installed
set -euo pipefail
source "$(dirname "$0")/_env.sh" "${1:-}"
if [ -f mytv/.round2-applied ]; then
  bash tools/restore.sh mytv/debloat-round2.txt com.google.android.apps.tv.launcherx && rm -f mytv/.round2-applied
fi
bash tools/theme.sh --reset || true
bash tools/restore.sh mytv/debloat.txt com.google.android.apps.tv.launcherx
if [ "${KEEP_LAUNCHER:-0}" != 1 ]; then
  tv 'pm uninstall com.gathin.tvhome' || true
fi
tv --screenshot mytv/shots/restaurado.png HOME --wait 3
echo "TV restaurada. Foto: mytv/shots/restaurado.png"
