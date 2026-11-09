#!/usr/bin/env bash
# Simulated run of mytv/run.sh against a fake TV (no real device). Usage:
#   run_scenario.sh <name> <ETHERNET|WIFI> [keep]   (keep = reuse the existing copy/state: a re-run)
set -uo pipefail
NAME=$1; TRANSPORT=$2; KEEP=${3:-}
SIM=/tmp/tvsim-$NAME
if [ -z "$KEEP" ]; then
  rm -rf "$SIM"; mkdir -p "$SIM"
  (cd /app && tar --exclude=.git --exclude=./mytv/shots --exclude='./mytv/backup-*' -cf - .) | (cd "$SIM" && tar -xf -)
  cp /app/test_reports/sim/fake_tv.py "$SIM/tools/tv.py"
  cp /app/test_reports/sim/fake_recovery.py "$SIM/tools/recovery.py"
  cp /app/test_reports/sim/fake_b64push.py "$SIM/tools/b64push.py"
  : > "$SIM/tv.log"
fi
export TVSIM_DIR=$SIM TVSIM_STATE=$SIM/state.json TVSIM_LOG=$SIM/tv.log TVSIM_LIST=$SIM/mytv/debloat.txt
export TVSIM_TRANSPORT=$TRANSPORT
export HOME=$SIM/home; mkdir -p "$HOME"
unset FORCE_SETUPWRAITH FORCE_HOME TVINPUT_ALLOW HANDLERS_ALLOW
cd "$SIM"
yes '' | bash mytv/run.sh > "$SIM/out-$TRANSPORT${KEEP:+-rerun}.txt" 2>&1
RC=${PIPESTATUS[1]}
echo "RC=$RC"
exit $RC
