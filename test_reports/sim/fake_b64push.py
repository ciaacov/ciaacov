#!/usr/bin/env python3
import os, sys
log = os.environ.get("TVSIM_LOG")
if log:
    open(log, "a").write("b64push " + " ".join(sys.argv[1:]) + "\n")
assert os.path.isfile(sys.argv[1]), "apk missing"
print(f"pushed {sys.argv[1]} -> {sys.argv[2]}")
