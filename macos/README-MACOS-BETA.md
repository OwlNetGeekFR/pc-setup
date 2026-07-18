# PC Setup macOS Beta

Cette préversion conserve le design des éditions Windows et Linux, avec un backend natif Swift utilisant WKWebView et Homebrew.

## Configuration requise

- macOS 12 Monterey ou une version plus récente.
- Mac Apple Silicon ou Intel 64 bits.
- Les outils de ligne de commande Xcode.
- Homebrew installé depuis [brew.sh](https://brew.sh/).

## Construire et installer

Extrayez l'archive, ouvrez Terminal dans le dossier puis exécutez :

```bash
chmod +x build-macos-app.sh install.sh uninstall.sh
./install.sh
```

Le script compile l'application, effectue une signature locale ad hoc et l'installe dans `~/Applications`.

## Limites de la bêta

- L'application n'est pas encore notariée par Apple.
- macOS peut demander une confirmation au premier lancement.
- Les mises à jour de macOS sont ouvertes dans Réglages Système et ne sont pas installées silencieusement.
- Les fonctions doivent être validées sur un véritable Mac avant publication.
