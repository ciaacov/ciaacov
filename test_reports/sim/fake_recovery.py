#!/usr/bin/env python3
"""Fake tools/recovery.py --save: keeps the first record (like the real one)."""
import json, os, sys
rec = os.path.join(os.environ["TVSIM_DIR"], "recovery-record.json")
if sys.argv[1:2] == ["--save"]:
    if os.path.exists(rec):
        print(f"keeping the recovery record from first run: {rec}")
    else:
        st = json.load(open(os.environ["TVSIM_STATE"])) if os.path.exists(os.environ["TVSIM_STATE"]) else {}
        json.dump({"created": "first", "disabled_before": st.get("disabled", [])}, open(rec, "w"))
        print(f"saved recovery record: {rec}")
