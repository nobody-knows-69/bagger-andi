# Rollt das Gateway (nginx-funnel) + Bagger-Andi auf ein Backup zurueck, das deploy-nas.ps1 angelegt hat.
# Aufruf: .\rollback-nas.ps1                 (letztes Backup, d.h. Stand vor dem letzten Deploy)
#         .\rollback-nas.ps1 -List           (Backups anzeigen)
#         .\rollback-nas.ps1 -Backup 20261028-193000
param([string]$Backup, [switch]$List)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\nas-lib.ps1"

if ($List) {
  Invoke-NasScript ($NasGatewayFns + @'
echo "Letztes: $(cat $BKROOT/LATEST 2>/dev/null)"
for d in $(ls -1 $BKROOT 2>/dev/null | grep -E '^[0-9]{8}-[0-9]{6}$'); do
  echo "  $d  mode=$(cat $BKROOT/$d/mode 2>/dev/null)  site=$([ -d $BKROOT/$d/site ] && echo ja || echo nein)"
done
'@)
  exit 0
}

$sel = if ($Backup) { "TS=$Backup" } else { 'TS=$(cat $BKROOT/LATEST)' }
Invoke-NasScript ($NasGatewayFns + $sel + "`n" + 'rollback_to "$TS"')
if ($LASTEXITCODE -ne 0) { Write-Host "Rollback mit Fehlern beendet (Code $LASTEXITCODE)." -ForegroundColor Red; exit 1 }
