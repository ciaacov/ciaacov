#!/usr/bin/env bash
# One command for the whole job on your MiTV-MOOR2: backup, debloat, install the launcher,
# with a TV screenshot after each step. Run from the repo root on a computer on your home network:
#   mytv/run.sh            (TV at 192.168.1.151)
#   TV_HOST=192.168.1.77 mytv/run.sh
set -euo pipefail
STOCK=com.google.android.apps.tv.launcherx
SHOTS=mytv/shots

step() { printf '\n=== %s ===\n' "$1"; }
pause() { read -r -p "Olhe a TV (e a foto $1) e aperte Enter para continuar (Ctrl+C para parar)... " _; }

step "1/6 Preparando as ferramentas (so na primeira vez demora um pouco)"
source "$(dirname "$0")/_env.sh" "${1:-}"

step "2/6 Conectando na TV $TV_HOST: na TV aparece 'Permitir depuracao USB?' -> marque 'Sempre permitir' e aperte OK"
tv --probe

step "3/6 Backup (copia de seguranca de tudo antes de mudar qualquer coisa)"
B="mytv/backup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$B"
tv 'pm list packages -f' > "$B/packages.txt"
tv 'pm list packages -d' > "$B/disabled.txt"
tv 'pm list packages -3' > "$B/third-party.txt"
tv 'getprop' > "$B/getprop.txt"
for ns in system secure global; do tv "settings list $ns" > "$B/settings-$ns.txt"; done
tv 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' > "$B/home.txt"
echo "Backup salvo em $B ($(wc -l < "$B/packages.txt") apps, $(wc -l < "$B/disabled.txt") ja desativados)"
tv --screenshot "$SHOTS/1-before.png" --wait 1
pause "$SHOTS/1-before.png"

step "4/6 Limpeza (so desativa, nada e apagado)"
SETUP=com.google.android.tungsten.setupwraith
# The TV is on a network cable, so turning off the setup wizard cannot take it offline (FORCE_SETUPWRAITH).
if tv 'dumpsys connectivity' | grep -o 'Transports: [A-Z]*' | grep ETHERNET >/dev/null; then
  echo "TV no cabo de rede: o assistente de configuracao ($SETUP) pode ser desligado com seguranca."
  export FORCE_SETUPWRAITH=1
fi
bash tools/disable.sh mytv/debloat.txt
if tv "pm list packages -e $SETUP" | tr -d '\r' | grep -x "package:$SETUP" >/dev/null; then
  echo >&2
  echo "PAREI AQUI: o assistente de configuracao do Google ($SETUP) continua ligado," >&2
  echo "e com ele ligado a nova tela inicial nao consegue ficar como Home." >&2
  echo "A TV nao esta usando o cabo de rede agora. Na TV: Configuracoes > Rede e Internet > sua rede Wi-Fi >" >&2
  echo "Esquecer rede, depois conecte nela de novo. Entao rode este mesmo comando outra vez." >&2
  exit 1
fi
tv --screenshot "$SHOTS/2-after-debloat.png" --wait 1
pause "$SHOTS/2-after-debloat.png"

step "5/6 Instalando a nova tela inicial"
APK=launcher/app/build/outputs/apk/release/app-release.apk
if [ -f mytv/tvhome-release.apk ]; then
  mkdir -p "$(dirname "$APK")" && cp mytv/tvhome-release.apk "$APK" && export SKIP_BUILD=1
fi
STOCK_LAUNCHER=$STOCK HOME_KEY_SERVICE=1 INPUT_KEY_SERVICE=1 bash launcher/build-and-install.sh
tv --screenshot "$SHOTS/3-new-home.png" HOME --wait 3
tv --screenshot "$SHOTS/4-grid.png" DPAD_DOWN --wait 2
tv input keyevent HOME >/dev/null

step "6/6 Conferindo"
echo "Tela inicial agora: $(tv 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' | tail -n 1)"
echo "Desativados agora: $(tv 'pm list packages -d' | wc -l) apps"
echo "Apps da barra encontrados na TV:"
tv 'pm list packages' | grep -Ei 'youtube.tv|smarttube|videomanager|disney|netflix|amazonvideo|hbo|Xplore|filemanager|estrongs|nbu.files' || true
echo "Gerenciadores de arquivos (copie estas linhas e mande para mim):"
tv 'pm list packages' | grep -Ei 'file|explor' || true
echo
echo "Pronto! Fotos: $SHOTS/  Backup: $B/  Para desfazer tudo: mytv/restore.sh"
