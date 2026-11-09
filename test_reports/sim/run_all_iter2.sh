#!/usr/bin/env bash
# Iteration 2 regression: on_cable() detection in mytv/run.sh step 4/6, against the fake TV.
# Usage: bash /app/test_reports/sim/run_all_iter2.sh   (prints PASS/FAIL per scenario)
set -u
S=/app/test_reports/sim; F=$S/fixtures; SETUP=com.google.android.tungsten.setupwraith
PASS=0; FAILN=0
clean() { unset TVSIM_NO_SYSFS TVSIM_CONN_FILE TVSIM_WIFI_FILE TVSIM_ETH_FILE TVSIM_FAIL_RE TVSIM_WIFI_CNAME FORCE_SETUPWRAITH KEEP_FORCE OLD_RUNSH; }
# check <name> <transport> <expect: ok|parei> [keep]
check() {
  local name=$1 tr=$2 exp=$3 keep=${4:-} rc out log
  bash $S/run_scenario.sh "$name" "$tr" $keep >/dev/null; rc=$?
  out=/tmp/tvsim-$name/out-$tr${keep:+-rerun}.txt; log=/tmp/tvsim-$name/tv.log
  local conn; conn=$(grep -m1 'Conexao da TV' "$out" || echo '(no Conexao line)')
  local dis=0 inst=0; grep -q "disable-user --user 0 $SETUP" "$log" && dis=1; grep -q 'pm install' "$log" && inst=1
  local home; home=$(grep 'Tela inicial agora' "$out" | tail -1)
  local ok=0
  if [ "$exp" = ok ]; then
    [ $rc = 0 ] && [ $dis = 1 ] && printf '%s' "$home" | grep -q com.gathin.tvhome && ok=1
  else
    [ $rc = 1 ] && [ $dis = 0 ] && [ $inst = 0 ] && grep -q 'PAREI AQUI' "$out" && { [ "$exp" = parei_old ] || grep -q "FORCE_SETUPWRAITH=1 bash mytv/run.sh" "$out"; } && ok=1
  fi
  if [ $ok = 1 ]; then PASS=$((PASS+1)); r=PASS; else FAILN=$((FAILN+1)); r=FAIL; fi
  echo "$r $name [$tr exp=$exp] rc=$rc setup_disabled=$dis pm_install=$inst | $conn | $home"
}
clean; check A_eth ETHERNET ok
clean; export TVSIM_NO_SYSFS=1; check U_eth_nosysfs ETHERNET ok
clean; check B_wifi WIFI parei
clean; export TVSIM_NO_SYSFS=1; check B_wifi_nosysfs WIFI parei
clean; export KEEP_FORCE=1 FORCE_SETUPWRAITH=1; check F_wifi_userforce WIFI ok
clean; export OLD_RUNSH=bd7a1e09 TVSIM_NO_SYSFS=1; check O_old_noforce ETHERNET parei_old
clean; export OLD_RUNSH=bd7a1e09 TVSIM_NO_SYSFS=1 KEEP_FORCE=1 FORCE_SETUPWRAITH=1; check O_old_force ETHERNET ok
clean; export TVSIM_CONN_FILE=$F/conn_eth_stale_wifi_connected.txt TVSIM_NO_SYSFS=1; check E1_staleeth_wificonn WIFI parei
clean; export TVSIM_CONN_FILE=$F/conn_request_only_eth.txt TVSIM_NO_SYSFS=1; check E2_reqeth_wificonn WIFI parei
clean; export TVSIM_CONN_FILE=$F/conn_eth_connected.txt TVSIM_WIFI_FILE=$F/wifi_disabled.txt TVSIM_NO_SYSFS=1; check E3_eth_wifidisabled ETHERNET ok
clean; export TVSIM_CONN_FILE=$F/conn_eth_connected.txt TVSIM_WIFI_FILE=$F/wifi_connected.txt TVSIM_NO_SYSFS=1; check E4_eth_plus_wifi_mNetworkInfo ETHERNET parei
clean; export TVSIM_FAIL_RE='^dumpsys (connectivity|wifi|ethernet)$|^cat /sys'; check E5_tvfail_oncable ETHERNET parei
clean; export TVSIM_FAIL_RE='^dumpsys connectivity$'; check E6_connfail_sysfs_ok ETHERNET parei
clean; export TVSIM_FAIL_RE='^dumpsys wifi$'; check E7_wififail_eth WIFI parei
clean; export TVSIM_CONN_FILE=$F/conn_eth_stale_wifi_connected.txt TVSIM_ETH_FILE=$F/eth_dump_down.txt TVSIM_WIFI_FILE=$F/wifi_connected.txt; check E8_ethdump_down_wifi WIFI parei
clean; export TVSIM_FAIL_RE="^dumpsys connectivity$" TVSIM_ETH_FILE=$F/eth_dump_down.txt TVSIM_WIFI_FILE=$F/wifi_enabled_no_mnetinfo.txt; check E9_connfail_ethdown_wifi WIFI parei
clean; export TVSIM_NO_SYSFS=1 TVSIM_FAIL_RE="^dumpsys connectivity$" TVSIM_ETH_FILE=$F/eth_dump_up.txt TVSIM_WIFI_FILE=$F/wifi_disabled.txt; check E10_ethdump_up_only ETHERNET parei
# re-run after failure: first WIFI fails, then cable plugged in -> same state re-run passes
clean; check R_rerun WIFI parei; clean; bash $S/run_scenario.sh R_rerun ETHERNET keep >/dev/null; echo "R_rerun second run rc=$? home=$(grep 'Tela inicial agora' /tmp/tvsim-R_rerun/out-ETHERNET-rerun.txt | tail -1)"
echo "TOTAL pass=$PASS fail=$FAILN"
