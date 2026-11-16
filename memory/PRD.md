# PRD: CleanYourTV for Xiaomi MiTV-MOOR2

## Original problem
Debloat the user's Android TV (Xiaomi MiTV-MOOR2, Google TV / Android 11, IP 192.168.1.151, network cable into the TV's own port, nothing on USB)
and replace its launcher with an Apple TV-style home screen. Back up first, verify each step with TV screenshots,
and deliver restore and build scripts plus a README. Never uninstall system packages.

## User choices
- Dock: 7 slots: YouTube, SmartTube, Disney+, Netflix, Prime Video, HBO Max, File manager
- Keep: streaming apps, voice search, Chromecast, system updates
- Connection: the user runs it on their own computer (the cloud sandbox can't reach the home LAN)

## Implemented (Nov 2026)
- launcher config.xml: 7 columns, dock_apps with package fallbacks, live_tv_package=com.mitv.livetv (hidden from grid), YouTube remote key 190
- APK built (JDK 17, SDK 34) -> mytv/tvhome-release.apk (excluded from .gitignore so it ships)
- mytv/debloat.txt (19 packages), mytv/run.sh (venv, probe, backup, disable, install with HOME_KEY_SERVICE=1 INPUT_KEY_SERVICE=1, screenshots), mytv/restore.sh, mytv/README.md
- Repo tests for the shipped config pass; the scripts pass a bash syntax check. Nothing has run on the real TV yet.

## Backlog
- Added: mytv/theme.sh (Aurora by default, any themes/<name>, --reset), mytv/round2.sh + debloat-round2.txt (8 pkgs: videos, printspooler, feedback, calendar sync, videoplayer, gallery, mediaexplorer, ci_mediatek; YouTube Music kept). restore.sh now also undoes round 2 and the theme. Both lists parse with recovery.py.
- P0: User runs mytv/run.sh and sends the screenshots back for review
- P1: Confirm the file manager package name and add it to dock_apps if it's missing
- P2: Optional themes (tools/theme.sh), second debloat round
- Added (PT-BR request): mytv/GUIA.md beginner guide (Windows Git Bash / Mac / Linux, getting the folder via Save to GitHub > Download ZIP, run order, sending back mytv/shots). Shared mytv/_env.sh picks py/python3/python and venv bin or Scripts (Windows). Scripts invoked with `bash` so missing exec bits from ZIP don't matter; prompts translated to Portuguese. Verified: fresh venv creation + run from another folder reaches the TV probe.
- Fixed TV IP: 192.168.1.151 (was a .51 typo). Scripts also accept the IP as an argument (bash mytv/run.sh <ip>); TV_HOST env still works.
- Bug fix (setupwraith RecoveryActivity took Home): disable.sh skipped setupwraith (Wi-Fi owner check). run.sh now sets FORCE_SETUPWRAITH=1 when dumpsys connectivity shows ETHERNET, and stops before the launcher install (PT message) if setupwraith is still enabled. Retry-safe: recovery record keeps the first run's state.
- Bug fix 2 (PAREI AQUI on a TV that IS on Ethernet): the sysfs carrier + ip route check failed on the real MiTV (likely shell can't read sysfs / Android policy routing). run.sh on_cable() now: cable if CONNECTED NetworkAgentInfo has ETHERNET, or dumpsys ethernet connected, or eth carrier=1; AND no CONNECTED Wi-Fi. Prints 'Conexao da TV: cabo= wifi_conectado='. Respects a user-set FORCE_SETUPWRAITH=1 (works with older ZIP too; verified in simulator). PAREI AQUI message suggests FORCE_SETUPWRAITH=1 bash mytv/run.sh.
- Hardening after iteration_2: on_cable returns 1 if dumpsys connectivity is unreadable; ETHERNET match anchored to 'NetworkAgentInfo{ ... state: CONNECTED/CONNECTED ... Transports: ETHERNET'; dumpsys ethernet regex fixed by testing agent. Simulator: bash test_reports/sim/run_all_iter2.sh -> 18/18 pass.
- Dock slot 7 = com.alphainventor.filemanager (user's TV has it + mediaexplorer). Set via mytv/theme-aurora/config.json dock_apps (runtime, no reinstall) and config.xml (other file-manager candidates removed, APK rebuilt to mytv/tvhome-release.apk). mytv/theme.sh default pushes mytv/theme-aurora. User's run.sh finished 6/6 with FORCE_SETUPWRAITH=1.
- Top-bar Ethernet/Wi-Fi pill hidden via show_network_pill:false in mytv/theme-aurora/config.json (undo: theme.sh --reset / restore.sh).
- SmartTube on user's TV is org.smarttube.stable: added first in SmartTube candidates (theme + config.xml, APK rebuilt). Theme fill_dock:false so a missing app never pulls the Settings gear into the dock. Dock: YouTube, SmartTube, Disney+, Netflix, Prime, HBO Max, File manager.
