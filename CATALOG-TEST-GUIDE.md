# Test du catalogue OwlSetup

L'outil `tools/Test-OwlSetupCatalog.ps1` contrôle les identifiants WinGet sans modifier le PC par défaut.

## Contrôle sans installation

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Test-OwlSetupCatalog.ps1
```

## Test ciblé de trois logiciels dans une machine de test

Fermez Chrome, Notepad++ et LibreOffice avant le test. Les logiciels déjà présents avant le test sont volontairement ignorés afin de protéger les données existantes.

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Test-OwlSetupCatalog.ps1 `
  -InstallAndUninstall `
  -ConfirmDestructiveTest "TEST OWLSETUP" `
  -Only Google.Chrome,Notepad++.Notepad++,TheDocumentFoundation.LibreOffice
```

## Test étendu dans une machine virtuelle

Créez d'abord un instantané de la machine virtuelle. Le mode standard exclut Nextcloud, les installations manuelles et les catégories sensibles.

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Test-OwlSetupCatalog.ps1 `
  -InstallAndUninstall `
  -ConfirmDestructiveTest "TEST OWLSETUP"
```

`-IncludeHighRisk` ajoute les composants, outils de sécurité et logiciels de virtualisation. Cette option ne doit être utilisée que dans une machine virtuelle jetable avec instantané.

Les rapports sont enregistrés dans `%LOCALAPPDATA%\OwlSetup\CatalogTests` et jamais sur le Bureau.
