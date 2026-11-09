# My TV: Xiaomi MiTV-MOOR2 (Google TV / Android 11) at 192.168.1.51

**Guia em português, passo a passo: [GUIA.md](GUIA.md)**

Everything is ready. You only need to run it from a computer on the same home network as the TV.

## What's in this folder

| File | What it does |
|---|---|
| `run.sh` | Does the whole job: backup, debloat, installs the new Home screen, takes a TV screenshot after each step and waits for you before going on. |
| `restore.sh` | Undoes all of it: turns every disabled app back on, gives Home back to Google TV, removes the new launcher. |
| `debloat.txt` | The 19 packages that get **disabled** (not uninstalled): Xiaomi analytics, ad and promo rows, the demo loop, preloaded extras. |
| `tvhome-release.apk` | The Apple TV-style launcher, already built (7-app dock). |

**Kept on, as you asked:** every streaming app, voice search and Google Assistant, Chromecast and Mi Cast,
system updates. Also kept, because the TV needs them: the HDMI/input switcher (Live TV app), the remote
and Bluetooth, the Netflix button, the network and TV services.

**Your dock, in this order:** YouTube, SmartTube, Disney+, Netflix, Prime Video, HBO Max, File manager.
Any of these that isn't installed is skipped and the next app moves up. The remote's YouTube button keeps working.

## Before you start (on the TV)

1. Developer options → **USB debugging ON** (you said network debugging is already on).
2. Keep the TV on and the remote nearby. The network cable is fine as it is.

## Run it (Mac or Linux; on Windows use WSL or Git Bash)

You need Python 3. Nothing else: no Android Studio, no Java.

```bash
cd cleanyourtv          # this repo, downloaded to your computer
bash mytv/run.sh
```

- At step 2 the TV shows **"Allow USB debugging?"**: tick *Always allow* and press **OK**.
- After each step, open the screenshot it names in `mytv/shots/` (or just look at the TV) and press Enter.
- The backup goes to `mytv/backup-<date>/`: full package list, disabled list, getprop, all settings.
- At the end it lists the file managers it found. If yours isn't in the dock, tell me its name and I'll add it.

If the TV has another IP by then: `TV_HOST=192.168.1.xx bash mytv/run.sh`

## After it's done

- Press Home a few times and open a few apps to check everything works.
- If the **Home button** ever shows Google TV again: Settings → System → Accessibility →
  CleanYourTV Home button → **On**. Switching it **Off** is also how you get the original Google TV home back for a moment.
- Switch **USB debugging OFF** in Developer options when you're finished.

## Optional extras (run after `run.sh`)

| Command | What it does |
|---|---|
| `bash mytv/theme.sh` | Puts the **Aurora** theme on: northern-lights wallpaper, deep navy background. Your dock stays the same. |
| `bash mytv/theme.sh cinematic` | Any other theme from `themes/` (aerial, glass, minimal, scenes, stockholm...), whenever you like. |
| `bash mytv/theme.sh --reset` | Back to the plain black look. |
| `bash mytv/round2.sh` | Second cleanup: turns off Google TV/Play Movies, printing, feedback reporter, calendar sync, the Xiaomi gallery/video player/media explorer, and the CI+ card module (`debloat-round2.txt`). YouTube Music and updates stay on. |

Each one saves a screenshot in `mytv/shots/`. `bash mytv/restore.sh` undoes all of it, round 2 and the theme included.

## Undo everything

```bash
bash mytv/restore.sh
```

## Rebuilding the launcher yourself (only if you change the dock)

Edit `launcher/app/src/main/res/values/config.xml` (`dock_apps`, `columns`), delete `mytv/tvhome-release.apk`,
and run `bash mytv/run.sh` again. It then builds with JDK 17 and Android SDK 34, or use `tools/docker-build.sh`.
