(() => {
  const logo = name => `assets/logos/${name}`;
  window.PC_SETUP_PLATFORM = "linux";
  window.PC_SETUP_CATALOG = [
    {id:"firefox",name:"Mozilla Firefox",category:"Navigateurs",desc:"Navigateur libre et respectueux",icon:"FF",color:"#ff7139",logo:logo("firefox.svg"),site:"https://www.mozilla.org/firefox/linux/",tags:["essentiel"]},
    {id:"google-chrome",name:"Google Chrome",category:"Navigateurs",desc:"Navigateur rapide de Google",icon:"CH",color:"#4285f4",logo:logo("googlechrome.svg"),site:"https://www.google.com/chrome/",tags:["essentiel"]},
    {id:"brave",name:"Brave",category:"Navigateurs",desc:"Navigation privée avec blocage intégré",icon:"BR",color:"#fb542b",logo:logo("brave.svg"),site:"https://brave.com/linux/",tags:["essentiel"]},
    {id:"vlc",name:"VLC media player",category:"Multimédia",desc:"Lecteur audio et vidéo universel",icon:"▶",color:"#f7931e",logo:logo("vlc.svg"),site:"https://www.videolan.org/vlc/download-linux.html",tags:["essentiel"]},
    {id:"libreoffice",name:"LibreOffice",category:"Bureautique",desc:"Suite bureautique complète et libre",icon:"LO",color:"#18a866",logo:logo("libreoffice.svg"),site:"https://www.libreoffice.org/download/download-libreoffice/",tags:["essentiel"]},
    {id:"sevenzip",name:"7-Zip / p7zip",category:"Utilitaires",desc:"Compression et extraction de fichiers",icon:"7z",color:"#64748b",logo:logo("sevenzip.svg"),site:"https://www.7-zip.org/download.html",tags:["essentiel"]},
    {id:"qbittorrent",name:"qBittorrent",category:"Internet",desc:"Client BitTorrent libre et sans publicité",icon:"qB",color:"#2f72b8",logo:logo("qbittorrent.svg"),site:"https://www.qbittorrent.org/download"},
    {id:"keepassxc",name:"KeePassXC",category:"Sécurité",desc:"Gestionnaire de mots de passe local",icon:"KX",color:"#6a9e3d",logo:logo("keepassxc.svg"),site:"https://keepassxc.org/download/",tags:["essentiel"]},
    {id:"bitwarden",name:"Bitwarden",category:"Sécurité",desc:"Gestionnaire de mots de passe chiffré",icon:"BW",color:"#175ddc",logo:logo("bitwarden.svg"),site:"https://bitwarden.com/download/"},
    {id:"gimp",name:"GIMP",category:"Création",desc:"Retouche et création d’images",icon:"GI",color:"#786753",logo:logo("gimp.svg"),site:"https://www.gimp.org/downloads/"},
    {id:"krita",name:"Krita",category:"Création",desc:"Dessin et peinture numérique",icon:"KR",color:"#8d56c7",logo:logo("krita.svg"),site:"https://krita.org/fr/telechargement/"},
    {id:"inkscape",name:"Inkscape",category:"Création",desc:"Création graphique vectorielle",icon:"IN",color:"#4e6070",site:"https://inkscape.org/release/"},
    {id:"audacity",name:"Audacity",category:"Multimédia",desc:"Enregistrement et montage audio",icon:"AU",color:"#3158c7",logo:logo("audacity.svg"),site:"https://www.audacityteam.org/download/linux/"},
    {id:"handbrake",name:"HandBrake",category:"Multimédia",desc:"Conversion et compression vidéo",icon:"HB",color:"#67a33f",logo:logo("handbrake.png"),site:"https://handbrake.fr/downloads.php"},
    {id:"kdenlive",name:"Kdenlive",category:"Création",desc:"Montage vidéo libre et complet",icon:"KD",color:"#4e83b8",logo:logo("kdenlive.svg"),site:"https://kdenlive.org/download/"},
    {id:"obs",name:"OBS Studio",category:"Multimédia",desc:"Enregistrement et streaming vidéo",icon:"OB",color:"#7565e8",logo:logo("obs.svg"),site:"https://obsproject.com/download",tags:["gaming"]},
    {id:"blender",name:"Blender",category:"Création",desc:"Création 3D, animation et rendu",icon:"BL",color:"#e57932",logo:logo("blender.svg"),site:"https://www.blender.org/download/"},
    {id:"calibre",name:"Calibre",category:"Bureautique",desc:"Bibliothèque de livres numériques",icon:"CA",color:"#66a950",logo:logo("calibre.png"),site:"https://calibre-ebook.com/download_linux"},
    {id:"thunderbird",name:"Mozilla Thunderbird",category:"Communication",desc:"Messagerie électronique libre",icon:"TB",color:"#4b73d0",logo:logo("thunderbird.svg"),site:"https://www.thunderbird.net/"},
    {id:"nextcloud",name:"Nextcloud Desktop",category:"Communication",desc:"Synchronisation avec un cloud personnel",icon:"NC",color:"#0082c9",logo:logo("nextcloud.svg"),site:"https://nextcloud.com/install/#install-clients"},
    {id:"discord",name:"Discord",category:"Communication",desc:"Messages, appels et communautés",icon:"DC",color:"#5865f2",logo:logo("discord.svg"),site:"https://discord.com/download",tags:["gaming"]},
    {id:"spotify",name:"Spotify",category:"Multimédia",desc:"Musique, podcasts et playlists",icon:"SP",color:"#1db954",logo:logo("spotify.svg"),site:"https://www.spotify.com/download/linux/"},
    {id:"telegram",name:"Telegram Desktop",category:"Communication",desc:"Messagerie rapide et sécurisée",icon:"TG",color:"#2aabee",site:"https://desktop.telegram.org/"},
    {id:"signal",name:"Signal Desktop",category:"Communication",desc:"Messagerie privée chiffrée",icon:"SG",color:"#3a76f0",site:"https://signal.org/download/"},
    {id:"steam",name:"Steam",category:"Gaming",desc:"Bibliothèque et plateforme de jeux",icon:"ST",color:"#2a75a8",logo:logo("steam.svg"),site:"https://store.steampowered.com/about/",tags:["gaming"]},
    {id:"heroic",name:"Heroic Games Launcher",category:"Gaming",desc:"Lanceur libre pour Epic et GOG",icon:"HG",color:"#7757d8",logo:logo("heroic.svg"),site:"https://heroicgameslauncher.com/",tags:["gaming"]},
    {id:"lutris",name:"Lutris",category:"Gaming",desc:"Gestionnaire de jeux Linux",icon:"LU",color:"#e77235",site:"https://lutris.net/downloads",tags:["gaming"]},
    {id:"vscode",name:"Visual Studio Code",category:"Développement",desc:"Éditeur de code extensible",icon:"VS",color:"#2789c7",logo:logo("vscode.svg"),site:"https://code.visualstudio.com/docs/setup/linux",tags:["dev"]},
    {id:"git",name:"Git",category:"Développement",desc:"Gestion de versions distribuée",icon:"G",color:"#f05032",logo:logo("git.svg"),site:"https://git-scm.com/download/linux",tags:["dev"]},
    {id:"nodejs",name:"Node.js LTS",category:"Développement",desc:"Runtime JavaScript longue durée",icon:"JS",color:"#68a063",logo:logo("nodejs.svg"),site:"https://nodejs.org/en/download/package-manager",tags:["dev"]},
    {id:"python",name:"Python 3",category:"Développement",desc:"Langage et environnement Python",icon:"PY",color:"#3776ab",logo:logo("python.svg"),site:"https://www.python.org/downloads/source/",tags:["dev"]},
    {id:"docker",name:"Docker",category:"Développement",desc:"Conteneurs et environnements isolés",icon:"DK",color:"#2496ed",logo:logo("docker.svg"),site:"https://docs.docker.com/engine/install/",tags:["dev"]},
    {id:"dbeaver",name:"DBeaver Community",category:"Développement",desc:"Gestion universelle de bases de données",icon:"DB",color:"#70533e",logo:logo("dbeaver.svg"),site:"https://dbeaver.io/download/",tags:["dev"]},
    {id:"filezilla",name:"FileZilla Client",category:"Internet",desc:"Transfert de fichiers FTP et SFTP",icon:"FZ",color:"#b93434",logo:logo("filezilla.svg"),site:"https://filezilla-project.org/download.php"},
    {id:"flatseal",name:"Flatseal",category:"Outils système",desc:"Gestion des autorisations Flatpak",icon:"FS",color:"#4f79b8",site:"https://flathub.org/apps/com.github.tchx84.Flatseal"},
    {id:"virt-manager",name:"Virtual Machine Manager",category:"Virtualisation",desc:"Gestion graphique de machines virtuelles",icon:"VM",color:"#3276a8",site:"https://virt-manager.org/"}
  ];

  const listeners = [];
  window.__pcSetupDispatch = message => listeners.forEach(listener => listener({data:message}));
  window.chrome = window.chrome || {};
  window.chrome.webview = {
    postMessage(message) {
      window.webkit.messageHandlers.pcsetup.postMessage(JSON.stringify(message));
    },
    addEventListener(type, listener) {
      if (type === "message") listeners.push(listener);
    }
  };

  document.addEventListener("DOMContentLoaded", () => {
    const replace = (selector, value) => { const element=document.querySelector(selector); if(element) element.textContent=value; };
    document.title = "PC Setup Linux BÊTA";
    const brandLogo = document.querySelector(".brand-app-logo");
    if (brandLogo) {
      brandLogo.src = "assets/branding/linux-tux.svg";
      brandLogo.alt = "Tux, mascotte de Linux";
      brandLogo.removeAttribute("aria-hidden");
      brandLogo.classList.add("linux-brand-logo");
    }
    const favicon = document.querySelector('link[rel="icon"]');
    if (favicon) favicon.href = "assets/branding/linux-tux.svg";
    replace("#buildSubtitle", "Linux beta");
    replace(".system-title strong", "Linux 64 bits");
    replace(".system-title small", "APT · DNF · Pacman · Flatpak");
    replace(".system-row:nth-of-type(2) b", "Auto");
    replace("#updates .label", "MAINTENANCE LINUX");
    replace("#updates h1", "Tout mettre à jour");
    replace("#updates .page-intro p", "Applications et paquets système proposés par votre distribution.");
    replace("#cleanup .label", "STOCKAGE LINUX");
    replace("#cleanup .page-intro p", "Nettoyez les caches utilisateur sans toucher à vos documents personnels.");
    replace("#diagnoseWinget", "Diagnostiquer");
    replace("#repairWinget", "Actualiser les sources");
    replace("#wingetDiagnosticText", "Vérifiez le gestionnaire de paquets détecté.");
    replace("#createRestorePoint", "Créer un instantané");
    replace("#restorePointText", "Disponible si Timeshift est installé.");
    replace("#openStartupSettings", "Ouvrir les applications");
    replace("#healthRestart", "Session active");
    document.querySelectorAll("body *").forEach(element => {
      if (element.children.length) return;
      element.textContent = element.textContent
        .replaceAll("WinGet", "gestionnaire de paquets")
        .replaceAll("winget", "gestionnaire de paquets")
        .replaceAll("Windows Update", "mises à jour système")
        .replaceAll("Windows", "Linux")
        .replaceAll("PowerShell", "terminal");
    });
  });
})();
