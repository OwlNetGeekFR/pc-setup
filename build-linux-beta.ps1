param(
    [string]$Version = "3.3.0-beta-linux.1"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$artifactRoot = Join-Path $root "artifacts\linux-beta"
$stage = Join-Path $artifactRoot "pc-setup-linux"
$archive = Join-Path $artifactRoot ("PC-Setup-Linux-" + $Version + ".tar.gz")

if ($Version -notmatch '^\d+\.\d+\.\d+-beta-linux\.\d+$') {
    throw "Utilisez un numéro comme 3.3.0-beta-linux.1."
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
Copy-Item -LiteralPath (Join-Path $root "linux\linux-bridge.js"), (Join-Path $root "linux\pc-setup-linux.py"), (Join-Path $root "linux\install.sh"), (Join-Path $root "linux\uninstall.sh"), (Join-Path $root "linux\README-LINUX-BETA.md"), (Join-Path $root "linux\BETA-TEST-CHECKLIST-LINUX.md") -Destination $stage

$indexPath = Join-Path $stage "index.html"
$index = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
$index = $index.Replace('<script src="app.js"></script>', '<script src="linux-bridge.js"></script>' + [Environment]::NewLine + '  <script src="app.js"></script>')
$index | Set-Content -LiteralPath $indexPath -Encoding UTF8

$launcherPath = Join-Path $stage "pc-setup-linux.py"
$launcher = Get-Content -LiteralPath $launcherPath -Raw -Encoding UTF8
$launcher = [regex]::Replace($launcher, 'VERSION = "[^"]+"', 'VERSION = "' + $Version + '"', 1)
$launcher | Set-Content -LiteralPath $launcherPath -Encoding UTF8

if (Test-Path -LiteralPath $archive) {
    Remove-Item -LiteralPath $archive -Force
}
Push-Location $artifactRoot
try {
    & tar.exe -czf (Split-Path $archive -Leaf) "pc-setup-linux"
    if ($LASTEXITCODE -ne 0) { throw "La création de l'archive Linux a échoué." }
} finally {
    Pop-Location
}

$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
@(
    "PC Setup Linux $Version"
    "Canal : bêta locale Linux, non publiée"
    "Archive : $archive"
    "SHA-256 : $hash"
) | Set-Content -LiteralPath (Join-Path $artifactRoot "LINUX-BETA-INFO.txt") -Encoding UTF8

Write-Host "Bêta Linux créée : $archive" -ForegroundColor Green
Write-Host "SHA-256 : $hash"
