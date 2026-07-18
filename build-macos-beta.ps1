param(
    [string]$Version = "3.3.0-beta-macos.1"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$artifactRoot = Join-Path $root "artifacts\macos-beta"
$stage = Join-Path $artifactRoot "pc-setup-macos"
$archive = Join-Path $artifactRoot ("PC-Setup-macOS-" + $Version + ".tar.gz")

if ($Version -notmatch '^\d+\.\d+\.\d+-beta-macos\.\d+$') {
    throw "Utilisez un numéro comme 3.3.0-beta-macos.1."
}

if (Test-Path -LiteralPath $stage) {
    $resolvedStage = [IO.Path]::GetFullPath($stage)
    $resolvedArtifact = [IO.Path]::GetFullPath($artifactRoot)
    if (-not $resolvedStage.StartsWith($resolvedArtifact, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Chemin de préparation invalide."
    }
    Remove-Item -LiteralPath $stage -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item -LiteralPath (Join-Path $root "index.html"), (Join-Path $root "app.js"), (Join-Path $root "styles.css") -Destination $stage
Copy-Item -LiteralPath (Join-Path $root "assets") -Destination $stage -Recurse
Copy-Item -LiteralPath (Join-Path $root "macos\macos-bridge.js"), (Join-Path $root "macos\PCSetupMac.swift"), (Join-Path $root "macos\build-macos-app.sh"), (Join-Path $root "macos\install.sh"), (Join-Path $root "macos\uninstall.sh"), (Join-Path $root "macos\README-MACOS-BETA.md"), (Join-Path $root "macos\BETA-TEST-CHECKLIST-MACOS.md") -Destination $stage

$swiftPath = Join-Path $stage "PCSetupMac.swift"
$swift = Get-Content -LiteralPath $swiftPath -Raw -Encoding UTF8
$swift = [regex]::Replace($swift, 'let pcSetupVersion = "[^"]+"', 'let pcSetupVersion = "' + $Version + '"', 1)
$swift | Set-Content -LiteralPath $swiftPath -Encoding UTF8

if (Test-Path -LiteralPath $archive) {
    Remove-Item -LiteralPath $archive -Force
}
Push-Location $artifactRoot
try {
    & tar.exe -czf (Split-Path $archive -Leaf) "pc-setup-macos"
    if ($LASTEXITCODE -ne 0) { throw "La création de l'archive macOS a échoué." }
} finally {
    Pop-Location
}

$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
@(
    "PC Setup macOS $Version"
    "Canal : bêta locale macOS, non publiée"
    "Archive : $archive"
    "Compilation finale de l'application : à effectuer sur un Mac"
    "SHA-256 : $hash"
) | Set-Content -LiteralPath (Join-Path $artifactRoot "MACOS-BETA-INFO.txt") -Encoding UTF8

Write-Host "Bêta macOS créée : $archive" -ForegroundColor Green
Write-Host "La compilation Swift finale doit être effectuée sur macOS."
Write-Host "SHA-256 : $hash"
