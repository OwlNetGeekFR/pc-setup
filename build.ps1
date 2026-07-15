param([string]$Output = "PC-Setup.exe")

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$version = "1.0.4078.44"
$packageRoot = Join-Path $root "packages\Microsoft.Web.WebView2.$version"
$nupkg = Join-Path $root "packages\Microsoft.Web.WebView2.$version.nupkg"

if (-not (Test-Path (Join-Path $packageRoot "lib\net462\Microsoft.Web.WebView2.Core.dll"))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $nupkg) | Out-Null
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2/$version" -OutFile $nupkg
    $zip = [IO.Path]::ChangeExtension($nupkg, ".zip")
    Copy-Item $nupkg $zip -Force
    Expand-Archive $zip -DestinationPath $packageRoot -Force
    Remove-Item $zip -Force
}

$core = Join-Path $packageRoot "lib\net462\Microsoft.Web.WebView2.Core.dll"
$forms = Join-Path $packageRoot "lib\net462\Microsoft.Web.WebView2.WinForms.dll"
$loader = Join-Path $packageRoot "runtimes\win-x64\native\WebView2Loader.dll"
$csc = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"

$arguments = @(
    "/nologo", "/target:winexe", "/optimize+", "/platform:x64",
    "/out:$Output", "/win32manifest:PC-Setup.manifest", "/win32icon:PC-Setup.ico",
    "/reference:System.Windows.Forms.dll", "/reference:System.Drawing.dll",
    "/reference:System.Core.dll", "/reference:System.Web.Extensions.dll",
    "/reference:$core", "/reference:$forms",
    "/resource:index.html,index.html", "/resource:app.js,app.js", "/resource:styles.css,styles.css",
    "/resource:Mettre-a-jour-mon-PC.ps1,Mettre-a-jour-mon-PC.ps1",
    "/resource:Liberer-espace-disque.ps1,Liberer-espace-disque.ps1",
    "/resource:Nettoyer-residus-applications.ps1,Nettoyer-residus-applications.ps1",
    "/resource:Installer-selection.ps1,Installer-selection.ps1",
    "/resource:assets\branding\pc-setup-logo-512.png,app-logo.png",
    "/resource:PC-Setup.ico,app-icon.ico",
    "/resource:$core,wv2core", "/resource:$forms,wv2forms", "/resource:$loader,wv2loader"
)

Get-ChildItem (Join-Path $root "assets\logos") -File | ForEach-Object {
    $arguments += "/resource:$($_.FullName),logos.$($_.Name)"
}
$arguments += "PCSetupWebView.cs"

Push-Location $root
try {
    & $csc $arguments
    if ($LASTEXITCODE -ne 0) { throw "La compilation a échoué avec le code $LASTEXITCODE." }
    $hash = Get-FileHash $Output -Algorithm SHA256
    Write-Host "Compilation terminée : $Output" -ForegroundColor Green
    Write-Host "SHA-256 : $($hash.Hash)"
} finally {
    Pop-Location
}
