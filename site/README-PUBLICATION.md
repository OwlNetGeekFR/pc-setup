# Site PC Setup

Ce dossier est un site statique autonome. Il peut être publié sur GitHub Pages, Netlify, Cloudflare Pages ou tout hébergement acceptant des fichiers HTML/CSS/JavaScript.

## Contenu

- `index.html` : page publique et démonstration interactive.
- `styles.css` : design responsive.
- `app.js` : simulations sans action sur le PC du visiteur.
- `assets/` : logo et icônes.
- `downloads/PC-Setup.exe` : application Windows proposée au téléchargement.
- `downloads/SHA256.txt` : empreinte permettant de vérifier l’intégrité du téléchargement.

## Tester localement

Depuis le dossier `site`, lancer :

```powershell
python -m http.server 4173
```

Puis ouvrir `http://127.0.0.1:4173/`.

## Publication

Déposer tout le contenu du dossier `site` à la racine de l’hébergement. Après chaque nouvelle compilation de PC Setup, remplacer `downloads/PC-Setup.exe` par la nouvelle version.

## Avant une diffusion publique

Il est fortement recommandé de signer numériquement l’exécutable avec un certificat de signature de code. Sans signature, Windows SmartScreen peut afficher un avertissement aux nouveaux utilisateurs.
