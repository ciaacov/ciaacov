#!/usr/bin/env bash
# Undo mytv/run.sh: re-enable every package mytv/debloat.txt disabled, give Home back to Google TV,
# and remove the CleanYourTV launcher.
#   mytv/restore.sh            (TV at 192.168.1.51)
#   KEEP_LAUNCHER=1 mytv/restore.sh   to leave the launcher installed
set -euo pipefail
cd "$(dirname "$0")/.."
export TV_HOST="${TV_HOST:-192.168.1.51}"
[ -x tools/venv/bin/python ] || { python3 -m venv tools/venv && tools/venv/bin/pip install -q -r tools/requirements.txt; }
tools/restore.sh mytv/debloat.txt com.google.android.apps.tv.launcherx
if [ "${KEEP_LAUNCHER:-0}" != 1 ]; then
  tools/venv/bin/python -I tools/tv.py 'pm uninstall com.gathin.tvhome' || true
fi
tools/venv/bin/python -I tools/tv.py --screenshot mytv/shots/restored.png HOME --wait 3
echo "Restored. Screenshot: mytv/shots/restored.png"
