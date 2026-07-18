# PC Setup Linux Beta

Cette préversion conserve le design de PC Setup et adapte les opérations aux distributions Linux.

Le logo Linux utilise Tux, créé à l'origine par Larry Ewing avec GIMP, puis adapté en SVG par Simon Budig et Garrett LeSage.

## Systèmes visés

- Ubuntu, Debian, Linux Mint et dérivés avec APT.
- Fedora et dérivés avec DNF.
- Arch Linux et dérivés avec Pacman.
- Applications Flatpak provenant de Flathub.

## Installation

Extrayez l'archive puis exécutez :

```bash
chmod +x install.sh
./install.sh
```

PC Setup apparaîtra ensuite dans le menu des applications.

## Dépendances graphiques

Ubuntu/Debian :

```bash
sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.1 policykit-1 flatpak
```

Fedora :

```bash
sudo dnf install python3-gobject gtk3 webkit2gtk4.1 polkit flatpak
```

Arch Linux :

```bash
sudo pacman -S python-gobject gtk3 webkit2gtk-4.1 polkit flatpak
```

Pour les logiciels proposés par Flatpak, Flathub doit être configuré :

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

## Limites de la bêta

- Cette archive n'est pas encore un AppImage.
- La détection des mises à jour varie selon la distribution.
- Les instantanés nécessitent Timeshift.
- Cette version doit être testée sur une vraie machine Linux ou dans une machine virtuelle avant publication.
