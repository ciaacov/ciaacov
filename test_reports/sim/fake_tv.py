#!/usr/bin/env python3
"""Fake tools/tv.py for simulating a Xiaomi MiTV-MOOR2 (Google TV 11). State in $TVSIM_STATE (JSON).
Env: TVSIM_TRANSPORT=ETHERNET|WIFI, TVSIM_LOG=path (every command logged), TVSIM_WIFI_CNAME=pkg (optional)."""
import json, os, re, sys

STATE = os.environ["TVSIM_STATE"]
LOG = os.environ.get("TVSIM_LOG")
SETUP = "com.google.android.tungsten.setupwraith"
LX = "com.google.android.apps.tv.launcherx"
TVH = "com.gathin.tvhome"
HOME_ACT = {SETUP: SETUP + "/.RecoveryActivity", LX: LX + "/com.google.android.apps.tv.launcherx.home.HomeActivity",
            TVH: TVH + "/.MainActivity", "com.android.tv.settings": "com.android.tv.settings/.system.FallbackHome"}
PRIO = {SETUP: 1, LX: 1, TVH: 0, "com.android.tv.settings": -1}
BASE_PKGS = ["android", "com.android.systemui", "com.android.tv.settings", LX, SETUP, "com.mitv.livetv",
             "com.google.android.youtube.tv", "com.netflix.ninja", "com.mitv.tvhome"]


def load():
    if os.path.exists(STATE):
        return json.load(open(STATE))
    pk = set(BASE_PKGS)
    for line in open(os.environ["TVSIM_LIST"]):
        line = line.strip()
        if line and not line.startswith("#"):
            pk.add(line.split()[0])
    return {"installed": sorted(pk), "disabled": [], "preferred": LX, "third": ["com.netflix.ninja"]}


def save(s):
    json.dump(s, open(STATE, "w"), indent=1)


def log(c):
    if LOG:
        with open(LOG, "a") as f:
            f.write(c.replace("\n", " ") + "\n")


def enabled(s, p):
    return p in s["installed"] and p not in s["disabled"]


def resolve_home(s):
    claim = [p for p in HOME_ACT if enabled(s, p) and p != "com.android.tv.settings"]
    if not claim:
        return HOME_ACT["com.android.tv.settings"] if enabled(s, "com.android.tv.settings") else "No activity found"
    top = max(PRIO[p] for p in claim)
    pref = s.get("preferred")
    if pref in claim and PRIO[pref] >= top:
        return HOME_ACT[pref]
    best = [p for p in claim if PRIO[p] == top]
    if SETUP in best:
        return HOME_ACT[SETUP]
    return HOME_ACT[best[0]] if len(best) == 1 else "android/com.android.internal.app.ResolverActivity"


def pm_list(s, args):
    pk = s["installed"]
    user0 = "--user" in args
    a = [x for x in args if x not in ("--user", "0")]
    flags = [x for x in a if x.startswith("-")]
    filt = [x for x in a if not x.startswith("-")]
    if "-e" in flags:
        pk = [p for p in pk if p not in s["disabled"]]
    if "-d" in flags:
        pk = [p for p in pk if p in s["disabled"]]
    if "-3" in flags:
        pk = [p for p in pk if p in s["third"]]
    if filt:
        pk = [p for p in pk if filt[0] in p]
    pre = "package:/system/app/x.apk=" if "-f" in flags else "package:"
    return "".join(f"{pre}{p}\r\n" for p in pk)


def run(s, c):
    log(c)
    c = c.strip()
    out = ""
    if c.startswith("s=$(getprop ro.build.version.sdk); for p in"):
        return ""  # TV_INPUT_HARDWARE guard: no listed package is an input driver
    if c.startswith("cmd package query-activities --brief -a android.intent.action.VIEW"):
        return "com.mitv.livetv/.LiveTvActivity\n==\ncom.android.tv.settings/.MainSettings\n"
    if c.startswith("pm list packages"):
        return pm_list(s, c.split()[3:])
    m = re.match(r"pm disable-user --user 0 (\S+)$", c)
    if m:
        p = m.group(1)
        if p in s["installed"]:
            if p not in s["disabled"]:
                s["disabled"].append(p)
            if p in HOME_ACT:
                s["preferred"] = None  # Android drops the Home preference when the HOME set changes
            return f"Package {p} new state: disabled-user\n"
        return f"Error: Unknown package: {p}\n"
    m = re.match(r"pm enable --user 0 (\S+)$", c)
    if m:
        p = m.group(1)
        if p in s["disabled"]:
            s["disabled"].remove(p)
            if p in HOME_ACT:
                s["preferred"] = None
        return f"Package {p} new state: enabled\n"
    if c.startswith("cmd package set-home-activity"):
        comp = c.split()[-1]
        if "$(" in c:  # rollback form: resolve-activity for stock launcher
            comp = HOME_ACT[LX]
        s["preferred"] = comp.split("/")[0]
        return "Success\n"
    if c.startswith("cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME"):
        r = resolve_home(s)
        return f"priority=0 preferredOrder=0 match=0x108000 specificIndex=-1 isDefault=true\n{r}\n"
    if c.startswith("cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME"):
        return "".join(f"{a}\n" for p, a in HOME_ACT.items() if enabled(s, p))
    if c.startswith("cat /sys/class/net/eth"):
        return "1\n" if os.environ.get("TVSIM_TRANSPORT", "ETHERNET") == "ETHERNET" else "0\n"
    if c.startswith("ip route get 1.1.1.1"):
        dev = "eth0" if os.environ.get("TVSIM_TRANSPORT", "ETHERNET") == "ETHERNET" else "wlan0"
        return f"1.1.1.1 via 192.168.1.1 dev {dev} table {dev} src 192.168.1.151 uid 2000\n"
    if c == "dumpsys connectivity":
        t = os.environ.get("TVSIM_TRANSPORT", "ETHERNET")
        return ("NetworkAgentInfo{ ni{[type: %s[], state: CONNECTED/CONNECTED]}  network{100}  nc{[ Transports: %s "
                "Capabilities: NOT_METERED&INTERNET&NOT_RESTRICTED&VALIDATED]} }\n" % (t, t))
    if c == "dumpsys wifi":
        cn = os.environ.get("TVSIM_WIFI_CNAME")
        return "Wi-Fi is enabled\n" + (f"  ID: 0 SSID: \"home\" cname={cn} \n" if cn else "")
    if c.startswith("getprop"):
        if c == "getprop ro.adb.secure":
            return "1\n"
        if c == "getprop ro.build.version.sdk":
            return "30\n"
        return "[ro.product.model]: [MiTV-MOOR2]\n[ro.build.version.sdk]: [30]\n"
    if c.startswith("settings list"):
        return "a=1\n"
    if c.startswith("pm install -r"):
        if TVH not in s["installed"]:
            s["installed"].append(TVH)
            s["third"].append(TVH)
        return "Success\n"
    if c.startswith("am start -W"):
        return "Starting: Intent { }\nStatus: ok\nActivity: com.gathin.tvhome/.MainActivity\n"
    if c.startswith("cmd appops set com.gathin.tvhome"):
        return re.search(r"echo (\w+) enabled", c).group(1) + " enabled\n"
    if c.startswith("pm revoke com.gathin.tvhome"):
        return "secure-settings-revoked\n"
    if c.startswith("pm grant com.gathin.tvhome android.permission.ACCESS_FINE_LOCATION"):
        return "location-granted\n"
    if c.startswith("dumpsys activity"):
        return ""
    return out  # everything else: silent success


def main():
    a = sys.argv[1:]
    s = load()
    if a and a[0] == "--probe":
        log("--probe"); print("connected to MiTV-MOOR2 (Android 11, SDK 30)")
    elif a and a[0] == "--screenshot":
        log("--screenshot " + " ".join(a[1:]))
        os.makedirs(os.path.dirname(a[1]) or ".", exist_ok=True)
        open(a[1], "wb").write(b"\x89PNG\r\n\x1a\nfake")
        print(f"saved {a[1]}")
    elif a and a[0] == "--batch":
        log("--batch")
        for line in sys.stdin:
            if line.strip():
                sys.stdout.write(run(s, line))
    else:
        sys.stdout.write(run(s, " ".join(a)))
    save(s)


if __name__ == "__main__":
    main()
