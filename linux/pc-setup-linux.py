#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys
import threading
import time
from pathlib import Path

try:
    import gi
    gi.require_version("Gtk", "3.0")
    try:
        gi.require_version("WebKit2", "4.1")
    except ValueError:
        gi.require_version("WebKit2", "4.0")
    from gi.repository import GLib, Gtk, WebKit2
except (ImportError, ValueError) as exc:
    print("PC Setup Linux nécessite GTK 3, PyGObject et WebKitGTK.")
    print("Ubuntu/Debian : sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.1")
    print("Fedora : sudo dnf install python3-gobject gtk3 webkit2gtk4.1")
    print("Arch : sudo pacman -S python-gobject gtk3 webkit2gtk-4.1")
    print(exc)
    raise SystemExit(1)

VERSION = "3.3.0-beta-linux.1"
APP_DIR = Path(__file__).resolve().parent
DATA_DIR = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "pc-setup"
LOG_DIR = DATA_DIR / "logs"
CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "pc-setup"

PACKAGES = {
    "firefox":{"apt":"firefox","dnf":"firefox","pacman":"firefox","flatpak":"org.mozilla.firefox"},
    "google-chrome":{"flatpak":"com.google.Chrome"},
    "brave":{"flatpak":"com.brave.Browser"},
    "vlc":{"apt":"vlc","dnf":"vlc","pacman":"vlc","flatpak":"org.videolan.VLC"},
    "libreoffice":{"apt":"libreoffice","dnf":"libreoffice","pacman":"libreoffice-fresh","flatpak":"org.libreoffice.LibreOffice"},
    "sevenzip":{"apt":"p7zip-full","dnf":"7zip","pacman":"7zip"},
    "qbittorrent":{"apt":"qbittorrent","dnf":"qbittorrent","pacman":"qbittorrent","flatpak":"org.qbittorrent.qBittorrent"},
    "keepassxc":{"apt":"keepassxc","dnf":"keepassxc","pacman":"keepassxc","flatpak":"org.keepassxc.KeePassXC"},
    "bitwarden":{"flatpak":"com.bitwarden.desktop"},
    "gimp":{"apt":"gimp","dnf":"gimp","pacman":"gimp","flatpak":"org.gimp.GIMP"},
    "krita":{"apt":"krita","dnf":"krita","pacman":"krita","flatpak":"org.kde.krita"},
    "inkscape":{"apt":"inkscape","dnf":"inkscape","pacman":"inkscape","flatpak":"org.inkscape.Inkscape"},
    "audacity":{"apt":"audacity","dnf":"audacity","pacman":"audacity","flatpak":"org.audacityteam.Audacity"},
    "handbrake":{"apt":"handbrake","dnf":"HandBrake-gui","pacman":"handbrake","flatpak":"fr.handbrake.ghb"},
    "kdenlive":{"apt":"kdenlive","dnf":"kdenlive","pacman":"kdenlive","flatpak":"org.kde.kdenlive"},
    "obs":{"apt":"obs-studio","dnf":"obs-studio","pacman":"obs-studio","flatpak":"com.obsproject.Studio"},
    "blender":{"apt":"blender","dnf":"blender","pacman":"blender","flatpak":"org.blender.Blender"},
    "calibre":{"apt":"calibre","dnf":"calibre","pacman":"calibre","flatpak":"com.calibre_ebook.calibre"},
    "thunderbird":{"apt":"thunderbird","dnf":"thunderbird","pacman":"thunderbird","flatpak":"org.mozilla.Thunderbird"},
    "nextcloud":{"apt":"nextcloud-desktop","dnf":"nextcloud-client","pacman":"nextcloud-client","flatpak":"com.nextcloud.desktopclient.nextcloud"},
    "discord":{"flatpak":"com.discordapp.Discord"},
    "spotify":{"flatpak":"com.spotify.Client"},
    "telegram":{"apt":"telegram-desktop","dnf":"telegram-desktop","pacman":"telegram-desktop","flatpak":"org.telegram.desktop"},
    "signal":{"flatpak":"org.signal.Signal"},
    "steam":{"apt":"steam-installer","dnf":"steam","pacman":"steam","flatpak":"com.valvesoftware.Steam"},
    "heroic":{"flatpak":"com.heroicgameslauncher.hgl"},
    "lutris":{"apt":"lutris","dnf":"lutris","pacman":"lutris","flatpak":"net.lutris.Lutris"},
    "vscode":{"flatpak":"com.visualstudio.code"},
    "git":{"apt":"git","dnf":"git","pacman":"git"},
    "nodejs":{"apt":"nodejs","dnf":"nodejs","pacman":"nodejs"},
    "python":{"apt":"python3","dnf":"python3","pacman":"python"},
    "docker":{"apt":"docker.io","dnf":"docker","pacman":"docker"},
    "dbeaver":{"flatpak":"io.dbeaver.DBeaverCommunity"},
    "filezilla":{"apt":"filezilla","dnf":"filezilla","pacman":"filezilla","flatpak":"org.filezillaproject.Filezilla"},
    "flatseal":{"flatpak":"com.github.tchx84.Flatseal"},
    "virt-manager":{"apt":"virt-manager","dnf":"virt-manager","pacman":"virt-manager"}
}

def command_exists(name):
    return shutil.which(name) is not None

def package_manager():
    for name in ("apt", "dnf", "pacman"):
        if command_exists(name):
            return name
    return "flatpak" if command_exists("flatpak") else None

def run(command, timeout=7200):
    return subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          text=True, errors="replace", timeout=timeout).returncode

def privileged(command):
    if os.geteuid() == 0:
        return command
    if command_exists("pkexec"):
        return ["pkexec"] + command
    return ["sudo"] + command

def human_size(size):
    value = float(max(0, size))
    for unit in ("o", "Ko", "Mo", "Go", "To"):
        if value < 1024 or unit == "To":
            return f"{value:.1f} {unit}".replace(".0 ", " ")
        value /= 1024

def folder_size(path):
    total = 0
    count = 0
    try:
        for root, dirs, files in os.walk(path):
            dirs[:] = [d for d in dirs if not os.path.islink(os.path.join(root, d))]
            for name in files:
                try:
                    total += os.path.getsize(os.path.join(root, name))
                    count += 1
                except OSError:
                    pass
    except OSError:
        pass
    return total, count

class PCSetupWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title=f"PC Setup Linux BÊTA — {VERSION}")
        self.set_default_size(1500, 920)
        self.set_size_request(1050, 700)
        icon_path = APP_DIR / "assets/branding/linux-tux.svg"
        if icon_path.exists():
            self.set_icon_from_file(str(icon_path))
        self.connect("destroy", Gtk.main_quit)
        self.manager = WebKit2.UserContentManager()
        self.manager.register_script_message_handler("pcsetup")
        self.manager.connect("script-message-received::pcsetup", self.on_message)
        self.webview = WebKit2.WebView.new_with_user_content_manager(self.manager)
        self.webview.get_settings().set_property("enable-developer-extras", False)
        self.webview.connect("decide-policy", self.on_policy)
        self.add(self.webview)
        self.webview.load_uri((APP_DIR / "index.html").as_uri())

    def send(self, payload):
        script = "window.__pcSetupDispatch(" + json.dumps(payload, ensure_ascii=False) + ");"
        GLib.idle_add(self.webview.run_javascript, script, None, None, None)

    def background(self, target, *args):
        threading.Thread(target=target, args=args, daemon=True).start()

    def on_policy(self, webview, decision, decision_type):
        if decision_type == WebKit2.PolicyDecisionType.NEW_WINDOW_ACTION:
            uri = decision.get_navigation_action().get_request().get_uri()
            subprocess.Popen(["xdg-open", uri])
            decision.ignore()
            return True
        return False

    def on_message(self, manager, result):
        try:
            raw = result.get_js_value().to_string()
            message = json.loads(raw)
            action = message.get("action", "")
            payload = message.get("payload") or {}
            handlers = {
                "get-app-info":self.app_info, "scan-installed":self.scan_installed,
                "scan-health":self.scan_health, "scan-updates":self.scan_updates,
                "install":self.install, "uninstall":self.uninstall, "batch-uninstall":self.batch_uninstall,
                "repair":self.repair, "update":self.update_all, "analyze-cleanup":self.analyze_cleanup,
                "cleanup":self.cleanup, "diagnose-winget":self.diagnose,
                "repair-winget":self.refresh_sources, "create-restore-point":self.restore_point,
                "scan-startup":self.scan_startup, "open-startup-settings":self.open_startup,
                "scan-disk":self.scan_disk, "load-history":self.load_history,
                "open-log":self.open_log, "scan-quarantine":self.empty_quarantine,
                "check-app-update":self.beta_update, "export-config":self.export_config,
                "import-config":self.import_config
            }
            handler = handlers.get(action)
            if handler:
                handler(payload)
        except Exception as exc:
            self.send({"type":"history-error","message":str(exc)})

    def app_info(self, payload):
        self.send({"type":"app-info","version":VERSION,"channel":"beta-linux","beta":True})

    def beta_update(self, payload):
        self.send({"type":"app-update-state","status":"beta","current":VERSION})

    def package_target(self, logical_id):
        mapping = PACKAGES.get(logical_id, {})
        manager = package_manager()
        if manager in mapping:
            return manager, mapping[manager]
        if command_exists("flatpak") and mapping.get("flatpak"):
            return "flatpak", mapping["flatpak"]
        return None, None

    def is_installed(self, logical_id):
        mapping = PACKAGES.get(logical_id, {})
        checks = []
        if command_exists("dpkg-query") and mapping.get("apt"):
            checks.append(["dpkg-query","-W","-f=${Status}",mapping["apt"]])
        if command_exists("rpm") and mapping.get("dnf"):
            checks.append(["rpm","-q",mapping["dnf"]])
        if command_exists("pacman") and mapping.get("pacman"):
            checks.append(["pacman","-Q",mapping["pacman"]])
        if command_exists("flatpak") and mapping.get("flatpak"):
            checks.append(["flatpak","info",mapping["flatpak"]])
        return any(run(check, 30) == 0 for check in checks)

    def scan_installed(self, payload):
        def work():
            ids = [item for item in payload.get("ids", []) if item in PACKAGES and self.is_installed(item)]
            self.send({"type":"installed-state","ids":ids,"count":len(ids),"method":"paquets"})
        self.background(work)

    def install_command(self, logical_id, reinstall=False):
        manager, package = self.package_target(logical_id)
        if not manager:
            return None
        if manager == "flatpak":
            return ["flatpak","install","--user","-y","flathub",package]
        if manager == "apt":
            return privileged(["apt-get","install","-y"] + (["--reinstall"] if reinstall else []) + [package])
        if manager == "dnf":
            return privileged(["dnf", "reinstall" if reinstall else "install", "-y", package])
        if manager == "pacman":
            return privileged(["pacman","-S","--noconfirm",package])

    def remove_command(self, logical_id):
        manager, package = self.package_target(logical_id)
        if manager == "flatpak":
            return ["flatpak","uninstall","--user","-y",package]
        if manager == "apt":
            return privileged(["apt-get","remove","-y",package])
        if manager == "dnf":
            return privileged(["dnf","remove","-y",package])
        if manager == "pacman":
            return privileged(["pacman","-R","--noconfirm",package])

    def write_log(self, prefix, lines):
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        name = f"PC-Setup-Linux-{prefix}-{time.strftime('%Y-%m-%d-%H%M%S')}.log"
        (LOG_DIR / name).write_text("\n".join(lines), encoding="utf-8")
        return name

    def install(self, payload):
        packages = [item for item in payload.get("packages", []) if item in PACKAGES]
        def work():
            self.send({"type":"install-start","total":len(packages)})
            success = failed = 0
            report = [f"PC SETUP LINUX {VERSION}", "INSTALLATION"]
            for index, logical_id in enumerate(packages, 1):
                self.send({"type":"install-progress","index":index,"total":len(packages),"id":logical_id})
                command = self.install_command(logical_id)
                valid = command is not None
                self.send({"type":"install-security","id":logical_id,"success":valid})
                code = run(command) if valid else 127
                ok = code == 0
                success += int(ok); failed += int(not ok)
                report.append(f"{logical_id}: {code}")
                self.send({"type":"install-item","index":index,"total":len(packages),"id":logical_id,"success":ok})
            name = self.write_log("Installation", report)
            self.send({"type":"install-complete","success":success,"failed":failed,"logName":name})
        self.background(work)

    def uninstall(self, payload):
        logical_id = payload.get("id")
        def work():
            self.send({"type":"uninstall-start","id":logical_id})
            command = self.remove_command(logical_id)
            code = run(command) if command else 127
            name = self.write_log("Desinstallation", [f"{logical_id}: {code}"])
            self.send({"type":"uninstall-complete","id":logical_id,"success":code == 0,"code":code,"logName":name})
        self.background(work)

    def batch_uninstall(self, payload):
        packages = [item for item in payload.get("packages", []) if item in PACKAGES]
        def work():
            success = failed = 0
            self.send({"type":"batch-uninstall-start","total":len(packages)})
            report = []
            for index, logical_id in enumerate(packages, 1):
                self.send({"type":"batch-uninstall-progress","index":index,"total":len(packages),"id":logical_id})
                command = self.remove_command(logical_id)
                code = run(command) if command else 127
                ok = code == 0; success += int(ok); failed += int(not ok)
                report.append(f"{logical_id}: {code}")
                self.send({"type":"batch-uninstall-item","id":logical_id,"success":ok})
            name = self.write_log("Desinstallation-groupee", report)
            self.send({"type":"batch-uninstall-complete","success":success,"failed":failed,"logName":name})
        self.background(work)

    def repair(self, payload):
        logical_id = payload.get("id")
        def work():
            self.send({"type":"repair-start","id":logical_id})
            self.send({"type":"repair-fallback","id":logical_id})
            command = self.install_command(logical_id, True)
            code = run(command) if command else 127
            name = self.write_log("Reparation", [f"{logical_id}: {code}"])
            self.send({"type":"repair-complete","id":logical_id,"success":code == 0,"code":code,"mode":"reinstall","logName":name})
        self.background(work)

    def scan_updates(self, payload):
        def work():
            self.send({"type":"updates-scanning"})
            updates = []
            manager = package_manager()
            try:
                if manager == "apt":
                    output = subprocess.check_output(["apt","list","--upgradable"], text=True, stderr=subprocess.STDOUT)
                    names = {line.split("/")[0] for line in output.splitlines()[1:] if "/" in line}
                    for logical_id, mapping in PACKAGES.items():
                        if mapping.get("apt") in names:
                            updates.append({"id":logical_id,"name":logical_id,"current":"installée","available":"nouvelle"})
                elif manager == "dnf":
                    output = subprocess.run(["dnf","check-update","-q"], text=True, stdout=subprocess.PIPE).stdout
                    names = {line.split()[0].split(".")[0] for line in output.splitlines() if line and not line.startswith("Obsoleting")}
                    for logical_id, mapping in PACKAGES.items():
                        if mapping.get("dnf") in names:
                            updates.append({"id":logical_id,"name":logical_id,"current":"installée","available":"nouvelle"})
                elif manager == "pacman":
                    output = subprocess.run(["checkupdates"], text=True, stdout=subprocess.PIPE).stdout if command_exists("checkupdates") else ""
                    names = {line.split()[0] for line in output.splitlines()}
                    for logical_id, mapping in PACKAGES.items():
                        if mapping.get("pacman") in names:
                            updates.append({"id":logical_id,"name":logical_id,"current":"installée","available":"nouvelle"})
                if command_exists("flatpak"):
                    output = subprocess.run(["flatpak","remote-ls","--updates","--columns=application"], text=True, stdout=subprocess.PIPE).stdout
                    flat_updates = set(output.splitlines())
                    for logical_id, mapping in PACKAGES.items():
                        if mapping.get("flatpak") in flat_updates and not any(item["id"] == logical_id for item in updates):
                            updates.append({"id":logical_id,"name":logical_id,"current":"installée","available":"nouvelle"})
                self.send({"type":"updates-found","updates":updates,"error":""})
            except Exception as exc:
                self.send({"type":"updates-found","updates":updates,"error":str(exc)})
        self.background(work)

    def update_all(self, payload):
        def work():
            manager = package_manager()
            self.send({"type":"update-start"})
            self.send({"type":"update-stage","stage":"sources","title":"Actualisation des sources","detail":manager or "Aucun gestionnaire","percent":15})
            code = 0
            if manager == "apt":
                code |= run(privileged(["apt-get","update"]))
                self.send({"type":"update-stage","stage":"applications","title":"Mise à jour des paquets","detail":"APT traite les nouvelles versions","percent":45})
                code |= run(privileged(["apt-get","upgrade","-y"]))
            elif manager == "dnf":
                self.send({"type":"update-stage","stage":"applications","title":"Mise à jour des paquets","detail":"DNF traite les nouvelles versions","percent":45})
                code |= run(privileged(["dnf","upgrade","-y"]))
            elif manager == "pacman":
                self.send({"type":"update-stage","stage":"applications","title":"Mise à jour des paquets","detail":"Pacman traite les nouvelles versions","percent":45})
                code |= run(privileged(["pacman","-Syu","--noconfirm"]))
            if command_exists("flatpak"):
                self.send({"type":"update-stage","stage":"windows","title":"Mise à jour Flatpak","detail":"Applications utilisateur","percent":80})
                code |= run(["flatpak","update","--user","-y"])
            name = self.write_log("Mise-a-jour", [f"Code: {code}"])
            self.send({"type":"update-complete","success":code == 0,"appsSuccess":code == 0,"windowsStarted":True,"code":code,"logName":name})
        self.background(work)

    def cleanup_paths(self, choices):
        home = Path.home()
        mapping = {
            "user-temp":[home / ".cache"],
            "windows-temp":[home / ".cache/thumbnails"],
            "recycle-bin":[home / ".local/share/Trash/files", home / ".local/share/Trash/info"],
            "delivery":[home / ".cache/fontconfig"],
            "app-leftovers":[home / ".cache/mozilla", home / ".cache/chromium"]
        }
        return [(choice, path) for choice in choices for path in mapping.get(choice, []) if path.exists()]

    def analyze_cleanup(self, payload):
        def work():
            self.send({"type":"cleanup-analysis-start"})
            items=[]; total=0
            for choice, path in self.cleanup_paths(payload.get("choices", [])):
                size, files=folder_size(path); total += size
                items.append({"label":choice,"path":str(path),"bytes":size,"files":files,"size":human_size(size)})
            self.send({"type":"cleanup-analysis","items":items,"size":human_size(total),"protectedFolders":[str(Path.home()/"Documents"),str(Path.home()/"Downloads")]})
        self.background(work)

    def cleanup(self, payload):
        choices = payload.get("choices", [])
        def work():
            before = shutil.disk_usage(Path.home()).free
            self.send({"type":"cleanup-start"})
            paths = self.cleanup_paths(choices)
            for index, (choice, path) in enumerate(paths, 1):
                self.send({"type":"cleanup-stage","label":str(path),"index":index,"total":len(paths),"percent":min(90, 10 + int(index/max(1,len(paths))*75))})
                for child in list(path.iterdir()) if path.exists() else []:
                    try:
                        if child.is_symlink() or child.is_file(): child.unlink()
                        elif child.is_dir(): shutil.rmtree(child)
                    except OSError:
                        pass
            if "components" in choices:
                manager=package_manager()
                if manager=="apt": run(privileged(["apt-get","clean"]))
                elif manager=="dnf": run(privileged(["dnf","clean","all"]))
                elif manager=="pacman": run(privileged(["pacman","-Sc","--noconfirm"]))
            gained=max(0,shutil.disk_usage(Path.home()).free-before)
            name=self.write_log("Nettoyage",[f"Espace récupéré: {human_size(gained)}"])
            self.send({"type":"cleanup-complete","success":True,"code":0,"recovered":f"{gained/1073741824:.2f}","logName":name})
        self.background(work)

    def scan_health(self, payload):
        def work():
            usage=shutil.disk_usage(Path.home())
            free_gb=usage.free/1073741824
            total_gb=usage.total/1073741824
            free_percent=round(usage.free/usage.total*100)
            score=max(45,min(100,70 + min(25,free_percent)))
            self.send({
                "type":"health-state","score":score,"updateCount":0,
                "freeGb":f"{free_gb:.1f}","freePercent":free_percent,
                "totalGb":f"{total_gb:.1f}","pendingRestart":False,
                "quarantineCount":0,"error":False
            })
        self.background(work)

    def diagnose(self, payload):
        manager=package_manager()
        self.send({"type":"winget-diagnostic","available":bool(manager),"sources":bool(manager),"version":manager or "absent","message":f"Gestionnaire détecté : {manager}" if manager else "Aucun gestionnaire compatible"})

    def refresh_sources(self, payload):
        def work():
            manager=package_manager(); self.send({"type":"winget-repair-start"})
            code=0
            if manager=="apt": code=run(privileged(["apt-get","update"]))
            elif manager=="dnf": code=run(privileged(["dnf","makecache"]))
            elif manager=="pacman": code=run(privileged(["pacman","-Sy"]))
            elif manager=="flatpak": code=run(["flatpak","update","--appstream","--user"])
            name=self.write_log("Sources",[f"Code: {code}"])
            self.send({"type":"winget-repair-complete","success":code==0,"code":code,"logName":name})
        self.background(work)

    def restore_point(self, payload):
        self.send({"type":"restore-point-start"})
        if command_exists("timeshift"):
            code=run(privileged(["timeshift","--create","--comments",f"PC Setup {VERSION}"]))
        else:
            code=127
        self.send({"type":"restore-point-complete","success":code==0,"code":code})

    def scan_startup(self, payload):
        items=[]
        for folder in (Path.home()/".config/autostart", Path("/etc/xdg/autostart")):
            if folder.exists():
                for entry in folder.glob("*.desktop"):
                    items.append({"name":entry.stem,"source":str(folder),"command":str(entry)})
        self.send({"type":"startup-state","items":items[:100]})

    def open_startup(self, payload):
        for command in (["gnome-session-properties"],["systemsettings5"],["xdg-open",str(Path.home()/".config/autostart")]):
            if command_exists(command[0]):
                subprocess.Popen(command); break

    def scan_disk(self, payload):
        def work():
            self.send({"type":"disk-scan-start"})
            items=[]
            for path in (Path.home()/"Documents",Path.home()/"Downloads",Path.home()/".cache",Path.home()/".local/share",Path.home()/".config"):
                if path.exists():
                    size,files=folder_size(path)
                    items.append({"name":path.name,"path":str(path),"bytes":size,"files":files,"size":human_size(size)})
            self.send({"type":"disk-scan-state","items":sorted(items,key=lambda item:item["bytes"],reverse=True)})
        self.background(work)

    def load_history(self, payload):
        LOG_DIR.mkdir(parents=True,exist_ok=True)
        items=[]
        for path in sorted(LOG_DIR.glob("*.log"),key=lambda p:p.stat().st_mtime,reverse=True)[:50]:
            items.append({"type":"Linux","name":path.name,"date":time.strftime("%d/%m/%Y %H:%M",time.localtime(path.stat().st_mtime)),"size":human_size(path.stat().st_size)})
        self.send({"type":"history-state","items":items})

    def open_log(self, payload):
        name=Path(payload.get("name","")).name
        path=LOG_DIR/name
        if path.exists(): subprocess.Popen(["xdg-open",str(path)])

    def empty_quarantine(self, payload):
        self.send({"type":"quarantine-state","items":[]})

    def export_config(self, payload):
        CONFIG_DIR.mkdir(parents=True,exist_ok=True)
        path=CONFIG_DIR/"configuration.json"
        path.write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding="utf-8")
        self.send({"type":"config-export-complete","success":True,"count":len(payload.get("selected",[])),"file":str(path)})

    def import_config(self, payload):
        path=CONFIG_DIR/"configuration.json"
        if not path.exists():
            self.send({"type":"config-import-error","message":"Aucune configuration sauvegardée."}); return
        data=json.loads(path.read_text(encoding="utf-8"))
        self.send({"type":"config-imported","packages":data.get("selected",[]),"cleanup":data.get("cleanup",[]),"file":str(path)})

def main():
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    window = PCSetupWindow()
    window.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
