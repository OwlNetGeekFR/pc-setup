(() => {
  const logo = name => `assets/logos/${name}`;
  window.PC_SETUP_PLATFORM = "macos";
  window.PC_SETUP_CATALOG = [
    {id:"firefox",name:"Mozilla Firefox",category:"Navigateurs",desc:"Navigateur libre et respectueux",icon:"FF",color:"#ff7139",logo:logo("firefox.svg"),site:"https://www.mozilla.org/firefox/mac/",tags:["essentiel"]},
    {id:"google-chrome",name:"Google Chrome",category:"Navigateurs",desc:"Navigateur rapide de Google",icon:"CH",color:"#4285f4",logo:logo("googlechrome.svg"),site:"https://www.google.com/chrome/",tags:["essentiel"]},
    {id:"brave-browser",name:"Brave",category:"Navigateurs",desc:"Navigation privée avec blocage intégré",icon:"BR",color:"#fb542b",logo:logo("brave.svg"),site:"https://brave.com/download/",tags:["essentiel"]},
    {id:"vlc",name:"VLC media player",category:"Multimédia",desc:"Lecteur audio et vidéo universel",icon:"▶",color:"#f7931e",logo:logo("vlc.svg"),site:"https://www.videolan.org/vlc/download-macosx.html",tags:["essentiel"]},
    {id:"libreoffice",name:"LibreOffice",category:"Bureautique",desc:"Suite bureautique complète et libre",icon:"LO",color:"#18a866",logo:logo("libreoffice.svg"),site:"https://www.libreoffice.org/download/download-libreoffice/",tags:["essentiel"]},
    {id:"the-unarchiver",name:"The Unarchiver",category:"Utilitaires",desc:"Extraction simple de nombreux formats",icon:"UA",color:"#4f82ba",site:"https://theunarchiver.com/",tags:["essentiel"]},
    {id:"sevenzip",name:"7-Zip",category:"Utilitaires",desc:"Compression et extraction en ligne de commande",icon:"7z",color:"#64748b",logo:logo("sevenzip.svg"),site:"https://www.7-zip.org/",brewType:"formula"},
    {id:"qbittorrent",name:"qBittorrent",category:"Internet",desc:"Client BitTorrent libre et sans publicité",icon:"qB",color:"#2f72b8",logo:logo("qbittorrent.svg"),site:"https://www.qbittorrent.org/download"},
    {id:"keepassxc",name:"KeePassXC",category:"Sécurité",desc:"Gestionnaire de mots de passe local",icon:"KX",color:"#6a9e3d",logo:logo("keepassxc.svg"),site:"https://keepassxc.org/download/",tags:["essentiel"]},
    {id:"bitwarden",name:"Bitwarden",category:"Sécurité",desc:"Gestionnaire de mots de passe chiffré",icon:"BW",color:"#175ddc",logo:logo("bitwarden.svg"),site:"https://bitwarden.com/download/"},
    {id:"gimp",name:"GIMP",category:"Création",desc:"Retouche et création d’images",icon:"GI",color:"#786753",logo:logo("gimp.svg"),site:"https://www.gimp.org/downloads/"},
    {id:"krita",name:"Krita",category:"Création",desc:"Dessin et peinture numérique",icon:"KR",color:"#8d56c7",logo:logo("krita.svg"),site:"https://krita.org/fr/telechargement/"},
    {id:"inkscape",name:"Inkscape",category:"Création",desc:"Création graphique vectorielle",icon:"IN",color:"#4e6070",site:"https://inkscape.org/release/"},
    {id:"audacity",name:"Audacity",category:"Multimédia",desc:"Enregistrement et montage audio",icon:"AU",color:"#3158c7",logo:logo("audacity.svg"),site:"https://www.audacityteam.org/download/mac/"},
    {id:"handbrake-app",name:"HandBrake",category:"Multimédia",desc:"Conversion et compression vidéo",icon:"HB",color:"#67a33f",logo:logo("handbrake.png"),site:"https://handbrake.fr/downloads.php"},
    {id:"kdenlive",name:"Kdenlive",category:"Création",desc:"Montage vidéo libre et complet",icon:"KD",color:"#4e83b8",logo:logo("kdenlive.svg"),site:"https://kdenlive.org/download/"},
    {id:"obs",name:"OBS Studio",category:"Multimédia",desc:"Enregistrement et streaming vidéo",icon:"OB",color:"#7565e8",logo:logo("obs.svg"),site:"https://obsproject.com/download",tags:["gaming"]},
    {id:"blender",name:"Blender",category:"Création",desc:"Création 3D, animation et rendu",icon:"BL",color:"#e57932",logo:logo("blender.svg"),site:"https://www.blender.org/download/"},
    {id:"calibre",name:"Calibre",category:"Bureautique",desc:"Bibliothèque de livres numériques",icon:"CA",color:"#66a950",logo:logo("calibre.png"),site:"https://calibre-ebook.com/download_osx"},
    {id:"thunderbird",name:"Mozilla Thunderbird",category:"Communication",desc:"Messagerie électronique libre",icon:"TB",color:"#4b73d0",logo:logo("thunderbird.svg"),site:"https://www.thunderbird.net/"},
    {id:"nextcloud",name:"Nextcloud Desktop",category:"Communication",desc:"Synchronisation avec un cloud personnel",icon:"NC",color:"#0082c9",logo:logo("nextcloud.svg"),site:"https://nextcloud.com/install/#install-clients"},
    {id:"discord",name:"Discord",category:"Communication",desc:"Messages, appels et communautés",icon:"DC",color:"#5865f2",logo:logo("discord.svg"),site:"https://discord.com/download",tags:["gaming"]},
    {id:"spotify",name:"Spotify",category:"Multimédia",desc:"Musique, podcasts et playlists",icon:"SP",color:"#1db954",logo:logo("spotify.svg"),site:"https://www.spotify.com/download/mac/"},
    {id:"telegram",name:"Telegram Desktop",category:"Communication",desc:"Messagerie rapide et sécurisée",icon:"TG",color:"#2aabee",site:"https://desktop.telegram.org/"},
    {id:"signal",name:"Signal Desktop",category:"Communication",desc:"Messagerie privée chiffrée",icon:"SG",color:"#3a76f0",site:"https://signal.org/download/"},
    {id:"steam",name:"Steam",category:"Gaming",desc:"Bibliothèque et plateforme de jeux",icon:"ST",color:"#2a75a8",logo:logo("steam.svg"),site:"https://store.steampowered.com/about/",tags:["gaming"]},
    {id:"heroic",name:"Heroic Games Launcher",category:"Gaming",desc:"Lanceur libre pour Epic et GOG",icon:"HG",color:"#7757d8",logo:logo("heroic.svg"),site:"https://heroicgameslauncher.com/",tags:["gaming"]},
    {id:"visual-studio-code",name:"Visual Studio Code",category:"Développement",desc:"Éditeur de code extensible",icon:"VS",color:"#2789c7",logo:logo("vscode.svg"),site:"https://code.visualstudio.com/download",tags:["dev"]},
    {id:"git",name:"Git",category:"Développement",desc:"Gestion de versions distribuée",icon:"G",color:"#f05032",logo:logo("git.svg"),site:"https://git-scm.com/download/mac",tags:["dev"],brewType:"formula"},
    {id:"node",name:"Node.js LTS",category:"Développement",desc:"Runtime JavaScript et npm",icon:"JS",color:"#68a063",logo:logo("nodejs.svg"),site:"https://nodejs.org/en/download",tags:["dev"],brewType:"formula"},
    {id:"python@3.13",name:"Python 3",category:"Développement",desc:"Langage et environnement Python",icon:"PY",color:"#3776ab",logo:logo("python.svg"),site:"https://www.python.org/downloads/macos/",tags:["dev"],brewType:"formula"},
    {id:"docker-desktop",name:"Docker Desktop",category:"Développement",desc:"Conteneurs et environnements isolés",icon:"DK",color:"#2496ed",logo:logo("docker.svg"),site:"https://docs.docker.com/desktop/setup/install/mac-install/",tags:["dev"]},
    {id:"dbeaver-community",name:"DBeaver Community",category:"Développement",desc:"Gestion universelle de bases de données",icon:"DB",color:"#70533e",logo:logo("dbeaver.svg"),site:"https://dbeaver.io/download/",tags:["dev"]},
    {id:"cyberduck",name:"Cyberduck",category:"Internet",desc:"Transfert de fichiers FTP, SFTP et cloud",icon:"CD",color:"#e3a42f",site:"https://cyberduck.io/download/"},
    {id:"rectangle",name:"Rectangle",category:"Outils système",desc:"Organisation rapide des fenêtres",icon:"RC",color:"#4d8ec7",site:"https://rectangleapp.com/",tags:["essentiel"]},
    {id:"iterm2",name:"iTerm2",category:"Développement",desc:"Terminal avancé pour macOS",icon:">_",color:"#45515d",logo:logo("terminal.svg"),site:"https://iterm2.com/",tags:["dev"]},
    {id:"utm",name:"UTM",category:"Virtualisation",desc:"Machines virtuelles pour Apple Silicon et Intel",icon:"UT",color:"#407eb5",site:"https://mac.getutm.app/"},
    {id:"zoom",name:"Zoom Workplace",category:"Communication",desc:"Réunions et visioconférences",icon:"ZM",color:"#2d8cff",logo:logo("zoom.svg"),site:"https://zoom.us/download"},
    {id:"rustdesk",name:"RustDesk",category:"Communication",desc:"Contrôle à distance libre",icon:"RD",color:"#e34a50",logo:logo("rustdesk.svg"),site:"https://rustdesk.com/"}
  ];

  const listeners = [];
  window.__pcSetupDispatch = message => listeners.forEach(listener => listener({data:message}));
  window.chrome = window.chrome || {};
  window.chrome.webview = {
    postMessage(message) { window.webkit.messageHandlers.pcsetup.postMessage(JSON.stringify(message)); },
    addEventListener(type, listener) { if (type === "message") listeners.push(listener); }
  };

  document.addEventListener("DOMContentLoaded", () => {
    const replace = (selector, value) => { const element=document.querySelector(selector); if(element) element.textContent=value; };
    document.title = "PC Setup macOS BÊTA";
    const brandLogo=document.querySelector(".brand-app-logo");
    if(brandLogo){brandLogo.src="assets/branding/macos-apple.svg";brandLogo.alt="Logo Apple";brandLogo.removeAttribute("aria-hidden");brandLogo.classList.add("macos-brand-logo");}
    const favicon=document.querySelector('link[rel="icon"]'); if(favicon)favicon.href="assets/branding/macos-apple.svg";
    replace("#buildSubtitle","macOS beta");
    replace(".system-title strong","macOS 12 ou supérieur");
    replace(".system-title small","Apple Silicon · Intel");
    replace(".system-row:nth-of-type(2) b","Homebrew");
    replace("#updates .label","MAINTENANCE macOS");
    replace("#updates .page-intro p","Applications Homebrew et mises à jour proposées par macOS.");
    replace("#cleanup .label","STOCKAGE macOS");
    replace("#cleanup .page-intro p","Nettoyez les caches utilisateur sans toucher à vos documents personnels.");
    replace("#diagnoseWinget","Diagnostiquer");
    replace("#repairWinget","Actualiser Homebrew");
    replace("#wingetDiagnosticText","Vérifiez Homebrew et son catalogue.");
    replace("#createRestorePoint","Ouvrir Time Machine");
    replace("#restorePointText","Utilisez Time Machine avant une opération importante.");
    replace("#openStartupSettings","Gérer dans macOS");
    document.querySelectorAll("body *").forEach(element=>{
      if(element.children.length)return;
      element.textContent=element.textContent
        .replaceAll("WinGet","Homebrew").replaceAll("winget","Homebrew")
        .replaceAll("Windows Update","Mise à jour de logiciels")
        .replaceAll("Windows","macOS").replaceAll("PowerShell","Terminal");
    });
  });
})();
