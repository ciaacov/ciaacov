#!/usr/bin/env bash
# One command for the whole job on your MiTV-MOOR2: backup, debloat, install the launcher,
# with a TV screenshot after each step. Run from the repo root on a computer on your home network:
#   mytv/run.sh            (TV at 192.168.1.51)
#   TV_HOST=192.168.1.77 mytv/run.sh
set -euo pipefail
cd "$(dirname "$0")/.."
export TV_HOST="${TV_HOST:-192.168.1.51}"
STOCK=com.google.android.apps.tv.launcherx
SHOTS=mytv/shots; mkdir -p "$SHOTS"

step() { printf '\n=== %s ===\n' "$1"; }
pause() { read -r -p "Check the TV and the screenshot $1, then press Enter to go on (Ctrl-C stops)... " _; }
tv() { tools/venv/bin/python -I tools/tv.py "$@"; }

step "1/6 Python tools"
[ -x tools/venv/bin/python ] || python3 -m venv tools/venv
tools/venv/bin/pip install -q -r tools/requirements.txt

step "2/6 Connect to $TV_HOST (accept 'Allow USB debugging?' on the TV, tick 'Always allow')"
tv --probe

step "3/6 Backup"
B="mytv/backup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$B"
tv 'pm list packages -f' > "$B/packages.txt"
tv 'pm list packages -d' > "$B/disabled.txt"
tv 'pm list packages -3' > "$B/third-party.txt"
tv 'getprop' > "$B/getprop.txt"
for ns in system secure global; do tv "settings list $ns" > "$B/settings-$ns.txt"; done
tv 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' > "$B/home.txt"
echo "Saved to $B ($(wc -l < "$B/packages.txt") packages, $(wc -l < "$B/disabled.txt") already disabled)"
tv --screenshot "$SHOTS/1-before.png" --wait 1
pause "$SHOTS/1-before.png"

step "4/6 Debloat (disable only, nothing uninstalled)"
tools/disable.sh mytv/debloat.txt
tv --screenshot "$SHOTS/2-after-debloat.png" --wait 1
pause "$SHOTS/2-after-debloat.png"

step "5/6 Install the launcher as Home"
APK=launcher/app/build/outputs/apk/release/app-release.apk
if [ -f mytv/tvhome-release.apk ]; then
  mkdir -p "$(dirname "$APK")" && cp mytv/tvhome-release.apk "$APK" && export SKIP_BUILD=1
fi
STOCK_LAUNCHER=$STOCK HOME_KEY_SERVICE=1 INPUT_KEY_SERVICE=1 launcher/build-and-install.sh
tv --screenshot "$SHOTS/3-new-home.png" HOME --wait 3
tv --screenshot "$SHOTS/4-grid.png" DPAD_DOWN --wait 2
tv input keyevent HOME >/dev/null

step "6/6 Check"
echo "Home now: $(tv 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' | tail -n 1)"
echo "Disabled now: $(tv 'pm list packages -d' | wc -l) packages"
echo "Dock apps found on this TV:"
tv 'pm list packages' | grep -Ei 'youtube.tv|smarttube|videomanager|disney|netflix|amazonvideo|hbo|Xplore|filemanager|estrongs|nbu.files' || true
echo "Other file managers (if yours is not above, tell me its name):"
tv 'pm list packages' | grep -Ei 'file|explor' || true
echo
echo "Done. Screenshots: $SHOTS/  Backup: $B/  Undo everything: mytv/restore.sh"
echo "When you're finished, switch USB debugging OFF in Developer options."
