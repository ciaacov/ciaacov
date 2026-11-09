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
# Turning off the setup wizard can only drop a Wi-Fi network, so allow it (FORCE_SETUPWRAITH) when the TV's
# connection is a cable: some sign of a live Ethernet link, and no connected Wi-Fi network at all.
on_cable() {
  local conn wifi eth=0 wlan=0
  conn=$(tv 'dumpsys connectivity' | tr -d '\r' | grep 'NetworkAgentInfo' | grep 'CONNECTED/CONNECTED' || true)
  printf '%s\n' "$conn" | grep 'Transports: ETHERNET' >/dev/null && eth=1
  printf '%s\n' "$conn" | grep 'Transports: WIFI' >/dev/null && wlan=1
  tv 'dumpsys ethernet' 2>/dev/null | tr -d '\r' | grep -Ei 'state: *CONNECTED|link.*up|isConnected.*true' >/dev/null && eth=1
  tv 'cat /sys/class/net/eth*/carrier 2>/dev/null' 2>/dev/null | grep -x '1' >/dev/null && eth=1
  wifi=$(tv 'dumpsys wifi' 2>/dev/null | tr -d '\r' || true)
  printf '%s\n' "$wifi" | grep -Ei 'mNetworkInfo.*state: CONNECTED|Wi-Fi is connected' >/dev/null && wlan=1
  echo "Conexao da TV: cabo=$eth wifi_conectado=$wlan"
  [ "$eth" = 1 ] && [ "$wlan" = 0 ]
}
if [ -z "${FORCE_SETUPWRAITH:-}" ] && on_cable; then
  echo "TV no cabo de rede: o assistente de configuracao ($SETUP) pode ser desligado com seguranca."
  export FORCE_SETUPWRAITH=1
fi
bash tools/disable.sh mytv/debloat.txt
# Fail closed: a TV that does not answer stops the run here (set -e) instead of going on to the install.
ALL=$(tv "pm list packages $SETUP" | tr -d '\r')
OFF=$(tv "pm list packages -d $SETUP" | tr -d '\r')
if printf '%s\n' "$ALL" | grep -x "package:$SETUP" >/dev/null && ! printf '%s\n' "$OFF" | grep -x "package:$SETUP" >/dev/null; then
  echo >&2
  echo "PAREI AQUI: o assistente de configuracao do Google ($SETUP) continua ligado," >&2
  echo "e com ele ligado a nova tela inicial nao consegue ficar como Home. Nada foi estragado." >&2
  echo "Para resolver: ligue o CABO DE REDE na TV (e confira em Configuracoes > Rede que ela esta usando o cabo)," >&2
  echo "depois rode este mesmo comando outra vez." >&2
  echo "Se a TV JA esta no cabo e o Wi-Fi desligado, rode assim:  FORCE_SETUPWRAITH=1 bash mytv/run.sh" >&2
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
