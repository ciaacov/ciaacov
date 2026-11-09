# Shared setup for the mytv/ scripts: TV address, Python venv (Mac, Linux and Windows Git Bash).
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export TV_HOST="${TV_HOST:-192.168.1.51}"
mkdir -p mytv/shots
vpy() { if [ -x tools/venv/bin/python ]; then echo tools/venv/bin/python; else echo tools/venv/Scripts/python.exe; fi; }
if [ ! -x "$(vpy)" ]; then
  if command -v py >/dev/null 2>&1; then py -3 -m venv tools/venv
  elif command -v python3 >/dev/null 2>&1; then python3 -m venv tools/venv
  else python -m venv tools/venv; fi
fi
"$(vpy)" -m pip install -q --disable-pip-version-check -r tools/requirements.txt
tv() { "$(vpy)" -I tools/tv.py "$@"; }
