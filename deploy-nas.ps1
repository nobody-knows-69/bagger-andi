# Deployt Bagger-Andi auf NAS2 hinter das Gateway (nginx-funnel): https://<gateway>/bagger-andi/
# Aufruf: .\deploy-nas.ps1            (Gateway-Dateien aus D:\LOS\ext_use, Website aus diesem Ordner)
#         .\deploy-nas.ps1 -SiteOnly  (nur Website-Dateien aktualisieren, Gateway unveraendert)
# Ablauf: Backup -> Upload in Staging -> nginx -t / compose config -> Umschalten -> Health-Check.
# Schlaegt der Health-Check fehl, wird automatisch auf das Backup zurueckgerollt.
# Manuelles Rollback: .\rollback-nas.ps1
# Quelle der Website ist index2.html (landet auf dem NAS als index.html). Das index.html im Repo
# ist nur noch die Weiterleitung von GitHub Pages auf das NAS.
param([string]$ExtUse = "D:\LOS\ext_use", [switch]$SiteOnly, [string]$SiteSource = "index2.html")
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\nas-lib.ps1"

# --- Lokale Vorpruefung -----------------------------------------------------
$gatewayFiles = "nginx.conf", "index.html", "docker-compose.yml" | ForEach-Object { Join-Path $ExtUse $_ }
$sourcePath = Join-Path $PSScriptRoot $SiteSource
if (-not (Test-Path $sourcePath)) { throw "Website-Quelle fehlt: $sourcePath" }
$html = Get-Content $sourcePath -Raw
if ($html -match 'http-equiv="refresh"') { throw "$SiteSource ist eine Weiterleitungsseite, nicht die Website." }
$refs = [regex]::Matches($html, '(?:src|href|poster)="([^"#:]+)"|url\([''"]?([^)''":]+)') |
  ForEach-Object { if ($_.Groups[1].Success) { $_.Groups[1].Value } else { $_.Groups[2].Value } } |
  Where-Object { $_ -notmatch '^/' } | ForEach-Object { [uri]::UnescapeDataString($_) } | Sort-Object -Unique
$siteFiles = @($SiteSource) + $refs
$missing = $siteFiles | Where-Object { -not (Test-Path (Join-Path $PSScriptRoot $_)) }
if ($missing) { throw "Fehlende Website-Dateien: $($missing -join ', ')" }
if (-not $SiteOnly) { $gatewayFiles | ForEach-Object { if (-not (Test-Path $_)) { throw "Fehlt: $_" } } }
$sizeMB = [math]::Round(($siteFiles | ForEach-Object { (Get-Item (Join-Path $PSScriptRoot $_)).Length } | Measure-Object -Sum).Sum / 1MB, 1)
Write-Host "Website: $($siteFiles.Count) Dateien, $sizeMB MB"

# --- 1. Backup + Staging anlegen --------------------------------------------
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
Write-Host "`n== 1. Backup $ts"
$out = Invoke-NasScript ($NasGatewayFns + @"
TS=$ts`n
"@ + @'
BK=$BKROOT/$TS
S mkdir -p "$BK" || exit 1
for f in nginx.conf index.html docker-compose.yml; do [ -f "$EXT/$f" ] && S cp -p "$EXT/$f" "$BK/"; done
S $D inspect nginx-funnel > /tmp/nf.json 2>/dev/null && S mv /tmp/nf.json "$BK/nginx-funnel.inspect.json"
if S $D inspect nginx-funnel --format '{{index .Config.Labels "com.docker.compose.project"}}' 2>/dev/null | grep -q .; then
  Swrite "$BK/mode" compose; else Swrite "$BK/mode" docker-run; fi
[ -d /volume1/docker/bagger-andi/site ] && S cp -a /volume1/docker/bagger-andi/site "$BK/site"
Swrite "$BKROOT/LATEST" "$TS"
S rm -rf "$EXT/.staging" /volume1/docker/bagger-andi/site.new
S mkdir -p "$EXT/.staging" "/volume1/docker/bagger-andi/site.new/neue pic"
S chown -R gman:users "$EXT/.staging" /volume1/docker/bagger-andi
echo "Backup: $BK (mode: $(cat "$BK/mode"))"
'@)
$out; if ($LASTEXITCODE -ne 0) { throw "Backup fehlgeschlagen, nichts geaendert." }

# --- 2. Upload ins Staging --------------------------------------------------
Write-Host "`n== 2. Upload"
if (-not $SiteOnly) { Copy-ToNas $gatewayFiles "$NasExtUse/.staging" }
# Website-Quelle als index.html hochladen (ueber temporaere Kopie)
$tmpDir = Join-Path ([IO.Path]::GetTempPath()) "bagger-andi-deploy"
New-Item -ItemType Directory -Force $tmpDir | Out-Null
Copy-Item $sourcePath (Join-Path $tmpDir "index.html") -Force
Copy-ToNas @(Join-Path $tmpDir "index.html") "/volume1/docker/bagger-andi/site.new"
$refs | Group-Object { Split-Path $_ -Parent } | ForEach-Object {
  $dir = if ($_.Name) { "/volume1/docker/bagger-andi/site.new/" + ($_.Name -replace '\\', '/') } else { "/volume1/docker/bagger-andi/site.new" }
  Copy-ToNas ($_.Group | ForEach-Object { Join-Path $PSScriptRoot $_ }) $dir
}
Write-Host "  hochgeladen"

# --- 3. Pruefen, umschalten, Health-Check (sonst Auto-Rollback) -------------
Write-Host "`n== 3. Pruefen + Umschalten"
$out = Invoke-NasScript ($NasGatewayFns + @"
TS=$ts; SITEONLY=$([int][bool]$SiteOnly)`n
"@ + @'
ST=$EXT/.staging
if [ "$SITEONLY" = 0 ]; then
  IMG=$(grep -m1 -oE 'nginx:[^ "]+' "$ST/docker-compose.yml")
  echo "  Image: $IMG"
  S $D pull -q "$IMG" >/dev/null || { echo "Image-Pull FEHLGESCHLAGEN -> Abbruch"; exit 2; }
  S $D run --rm -v "$ST/nginx.conf:/etc/nginx/conf.d/default.conf:ro" "$IMG" nginx -t -q \
    || { echo "nginx -t FEHLGESCHLAGEN -> Abbruch, nichts umgeschaltet"; exit 2; }
  (cd "$ST" && S $DC config -q) || { echo "docker-compose config FEHLGESCHLAGEN -> Abbruch"; exit 2; }
  echo "  Konfiguration gueltig"
fi
# Umschalten
S rm -rf /volume1/docker/bagger-andi/site.old
[ -d /volume1/docker/bagger-andi/site ] && S mv /volume1/docker/bagger-andi/site /volume1/docker/bagger-andi/site.old
S mv /volume1/docker/bagger-andi/site.new /volume1/docker/bagger-andi/site
S rm -rf /volume1/docker/bagger-andi/site.old
if [ "$SITEONLY" = 0 ]; then
  for f in nginx.conf index.html docker-compose.yml; do S cp "$ST/$f" "$EXT/$f"; done
  S $D inspect nginx-funnel --format '{{index .Config.Labels "com.docker.compose.project"}}' 2>/dev/null | grep -q . \
    || S $D rm -f nginx-funnel >/dev/null          # alter docker-run-Container muss weichen
  (cd "$EXT" && S $DC up -d) || { rollback_to "$TS"; exit 3; }
fi
# Bind-Mount haengt am alten (geloeschten) Ordner -> Container neu starten, damit er site/ neu einbindet
S $D restart bagger-andi >/dev/null || { rollback_to "$TS"; exit 3; }
S rm -rf "$ST"
sleep 3
echo "  Health-Check:"
rc=0
check / 200 || rc=1
check /grafana/ 200 301 302 || rc=1
check /bagger-andi 301 || rc=1
check /bagger-andi/ 200 || rc=1
check /bagger-andi/pic001.jpeg 200 || rc=1
check /bagger-andi/neue%20pic/ani.png 200 || rc=1
check /bagger-andi/bagger-andi.mp4 200 || rc=1
check /grafana/login 200 || rc=1
hdr /bagger-andi/ Strict-Transport-Security || rc=1
hdr /bagger-andi/ Content-Security-Policy || rc=1
for c in nginx-funnel bagger-andi; do
  st=$(S $D inspect "$c" --format '{{.State.Status}} restarts={{.RestartCount}}' 2>/dev/null)
  case "$st" in "running restarts=0") echo "  OK   $c $st";; *) echo "  FAIL $c $st"; rc=1;; esac
done
if [ $rc != 0 ]; then rollback_to "$TS"; exit 4; fi
echo "== Deploy OK (Backup fuer Rollback: $TS)"
'@)
$out
switch ($LASTEXITCODE) {
  0 { Write-Host "`nFertig. Lokal testen: https://gzone.myds.me:8443/bagger-andi/   Rollback: .\rollback-nas.ps1" -ForegroundColor Green }
  2 { Write-Host "`nAbgebrochen vor dem Umschalten, Gateway unveraendert." -ForegroundColor Yellow; exit 2 }
  default { Write-Host "`nDeploy fehlgeschlagen (Code $LASTEXITCODE), Rollback wurde ausgefuehrt (siehe oben)." -ForegroundColor Red; exit $LASTEXITCODE }
}
