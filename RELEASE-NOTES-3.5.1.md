# OwlSetup 3.5.1

Cette version renforce la désinstallation des applications et la validation du catalogue WinGet.

## Correctifs

- Correction de la sélection des applications installées depuis les cartes du catalogue.
- Désinstallation plus fiable pour les logiciels installés pour l’utilisateur ou pour toute la machine.
- Nouvelle vérification après désinstallation afin de ne plus annoncer un succès si l’application est encore présente.
- Les codes Windows indiquant qu’un redémarrage est requis sont désormais correctement interprétés.

## Sécurité

- L’outil de validation du catalogue fonctionne en audit seul par défaut et ne supprime jamais une application déjà présente avant un test.
- Nextcloud reste disponible pour l’installation, la réparation et la désinstallation comme toutes les autres applications du catalogue.

## Tests

- Ajout d’un script d’audit des identifiants WinGet du catalogue.
- Le mode d’installation/désinstallation exige les droits administrateur et une confirmation explicite.
- Les rapports de test sont enregistrés dans `%LOCALAPPDATA%\OwlSetup\CatalogTests`, jamais sur le Bureau.

> OwlSetup 3.5.1 reste en thème sombre uniquement. Cette version n’est pas encore signée numériquement : téléchargez-la depuis la Release GitHub officielle et vérifiez son empreinte dans `SHA256.txt`.
