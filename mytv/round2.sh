#!/usr/bin/env bash
# Second cleanup round: disables mytv/debloat-round2.txt, with a screenshot before and after.
#   mytv/round2.sh            (TV at 192.168.1.51)
set -euo pipefail
cd "$(dirname "$0")/.."
export TV_HOST="${TV_HOST:-192.168.1.51}"
mkdir -p mytv/shots
[ -x tools/venv/bin/python ] || { python3 -m venv tools/venv && tools/venv/bin/pip install -q -r tools/requirements.txt; }
tv() { tools/venv/bin/python -I tools/tv.py "$@"; }
tv --probe
tv --screenshot mytv/shots/5-before-round2.png HOME --wait 2
tools/disable.sh mytv/debloat-round2.txt
touch mytv/.round2-applied
tv --screenshot mytv/shots/6-after-round2.png HOME --wait 3
echo "Disabled now: $(tv 'pm list packages -d' | wc -l) packages"
echo "Done. Screenshots: mytv/shots/5-before-round2.png and 6-after-round2.png. Undo: mytv/restore.sh"
