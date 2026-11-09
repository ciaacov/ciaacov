#!/usr/bin/env bash
# Second cleanup round: disables mytv/debloat-round2.txt, with a screenshot before and after.
set -euo pipefail
source "$(dirname "$0")/_env.sh"
tv --probe
tv --screenshot mytv/shots/5-antes-limpeza2.png HOME --wait 2
bash tools/disable.sh mytv/debloat-round2.txt
touch mytv/.round2-applied
tv --screenshot mytv/shots/6-depois-limpeza2.png HOME --wait 3
echo "Desativados agora: $(tv 'pm list packages -d' | wc -l) apps"
echo "Pronto! Fotos: mytv/shots/5-antes-limpeza2.png e 6-depois-limpeza2.png. Para desfazer: mytv/restore.sh"
