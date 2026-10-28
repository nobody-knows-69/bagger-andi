# Gemeinsame Helfer fuer die NAS-Skripte. Einbinden mit: . "$PSScriptRoot\nas-lib.ps1"
# SSH per Key; sudo-Passwort aus dem Windows-Schluesselbund (generic credential, siehe nas-set-cred.ps1).
# Das Passwort wird nur per stdin an sudo -S weitergereicht, nie ausgegeben oder gespeichert.

$NasUser = "gman"; $NasHost = "192.168.165.73"; $NasCredTarget = "NAS2-sudo"

if (-not ("NasCred" -as [type])) {
Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public class NasCred {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  struct CREDENTIAL { public int Flags; public int Type; public string TargetName; public string Comment;
    public long LastWritten; public int CredentialBlobSize; public IntPtr CredentialBlob; public int Persist;
    public int AttributeCount; public IntPtr Attributes; public string TargetAlias; public string UserName; }
  [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
  static extern bool CredRead(string target, int type, int flags, out IntPtr cred);
  [DllImport("advapi32.dll")] static extern void CredFree(IntPtr cred);
  public static string Get(string target) {
    IntPtr p; if (!CredRead(target, 1, 0, out p)) return null;   // 1 = CRED_TYPE_GENERIC
    var c = (CREDENTIAL)Marshal.PtrToStructure(p, typeof(CREDENTIAL));
    if (c.CredentialBlobSize == 0) { CredFree(p); return null; }
    string pw = Marshal.PtrToStringUni(c.CredentialBlob, c.CredentialBlobSize / 2);
    CredFree(p); return pw;
  }
}
'@
}

# Fuehrt ein bash-Skript auf dem NAS aus. Darin stehen zur Verfuegung:
#   S <cmd...>   -> cmd mit sudo
#   D            -> Pfad zu docker, DC -> Pfad zu docker-compose
# Gibt stdout+stderr zeilenweise zurueck; $LASTEXITCODE = Exit-Code des Skripts.
function Invoke-NasScript([string]$Script) {
  $pw = [NasCred]::Get($NasCredTarget)
  if (-not $pw) { throw "Credential '$NasCredTarget' fehlt oder ist leer. Anlegen mit: .\nas-set-cred.ps1" }
  $prelude = @'
IFS= read -r PW
PW=${PW%$'\r'}              # CRLF entfernen
PW=${PW#$'\xef\xbb\xbf'}     # .NET setzt ein UTF-8-BOM vor stdin
S() { printf '%s\n' "$PW" | sudo -S -p '' "$@"; }
# Swrite <datei> <text>: Datei als root schreiben. Nie "echo x | S tee" verwenden -
# S belegt stdin selbst, tee bekaeme sonst nichts (oder bei gecachtem sudo das Passwort).
Swrite() { S sh -c 'printf "%s\n" "$2" > "$1"' _ "$1" "$2"; }
D=/usr/local/bin/docker; DC=/usr/local/bin/docker-compose
S true 2>/dev/null || { echo "sudo FEHLGESCHLAGEN"; exit 99; }
exec 2>&1
'@
  # PowerShell 5.1 zerlegt Anfuehrungszeichen in nativen Argumenten -> Skript base64-kodiert uebergeben.
  $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes((($prelude + "`n" + $Script) -replace "`r", "")))
  $psi = New-Object Diagnostics.ProcessStartInfo "ssh", "-o BatchMode=yes $NasUser@$NasHost `"bash -c 'bash <(echo $b64 | base64 -d)'`""
  $psi.UseShellExecute = $false; $psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
  $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
  $proc = [Diagnostics.Process]::Start($psi)
  $bytes = (New-Object Text.UTF8Encoding $false).GetBytes($pw + "`n")
  $proc.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length); $proc.StandardInput.Close()
  [Array]::Clear($bytes, 0, $bytes.Length); Remove-Variable pw
  $outText = $proc.StandardOutput.ReadToEnd()
  $null = $proc.StandardError.ReadToEnd()
  $proc.WaitForExit()
  $global:LASTEXITCODE = $proc.ExitCode
  ($outText -replace "`r", "").TrimEnd("`n") -split "`n"
}

# Kopiert lokale Dateien per scp (als gman, ohne sudo) in ein NAS-Verzeichnis (Leerzeichen erlaubt).
function Copy-ToNas([string[]]$Files, [string]$RemoteDir) {
  $ErrorActionPreference = "Continue"   # PS 5.1: stderr-Warnungen von scp sonst als Fehler
  scp -q -O -o BatchMode=yes @Files "${NasUser}@${NasHost}:'$RemoteDir/'" 2>&1 | Where-Object { "$_" -notmatch 'post-quantum|store now|openssh.com/pq' }
  if ($LASTEXITCODE -ne 0) { throw "scp nach $RemoteDir fehlgeschlagen" }
}

# --- Gateway (nginx-funnel) -------------------------------------------------
$NasExtUse  = "/volume1/docker/ext_use"
$NasBackups = "/volume1/docker/ext_use/backups"

# Bash-Funktionen fuer Health-Check und Rollback; werden vor Remote-Skripte gehaengt.
$NasGatewayFns = @'
EXT=/volume1/docker/ext_use; BKROOT=$EXT/backups
code() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "http://127.0.0.1:8080$1"; }
check() {  # check <pfad> <erlaubte codes...>
  local p=$1; shift; local c; c=$(code "$p")
  for ok in "$@"; do [ "$c" = "$ok" ] && { echo "  OK   $p -> $c"; return 0; }; done
  echo "  FAIL $p -> $c (erwartet: $*)"; return 1
}
hdr() {  # hdr <pfad> <header-name>: Header muss in der Antwort vorkommen
  curl -s -D - -o /dev/null --max-time 10 "http://127.0.0.1:8080$1" | grep -qi "^$2:" \
    && echo "  OK   $1 hat $2" || { echo "  FAIL $1 ohne $2"; return 1; }
}
# Stellt den Stand aus Backup $1 wieder her (Dateien + Container).
rollback_to() {
  local BK=$BKROOT/$1
  [ -f "$BK/nginx.conf" ] || { echo "Backup $BK nicht gefunden"; return 1; }
  echo "== Rollback auf $1"
  S $D rm -f bagger-andi nginx-funnel >/dev/null 2>&1
  for f in nginx.conf index.html docker-compose.yml; do [ -f "$BK/$f" ] && S cp -p "$BK/$f" "$EXT/$f"; done
  if [ -d "$BK/site" ]; then S rm -rf /volume1/docker/bagger-andi/site && S cp -a "$BK/site" /volume1/docker/bagger-andi/site; fi
  if [ "$(cat "$BK/mode" 2>/dev/null)" = "compose" ]; then
    (cd "$EXT" && S $DC up -d --remove-orphans)
  else   # urspruenglicher Start per docker run (Stand vor der Compose-Umstellung)
    S $D run -d --name nginx-funnel --restart unless-stopped -p 127.0.0.1:8080:80 \
      -v "$EXT/nginx.conf:/etc/nginx/conf.d/default.conf:ro" \
      -v "$EXT/index.html:/usr/share/nginx/html/index.html:ro" nginx:1.27-alpine >/dev/null
  fi
  sleep 3
  local rc=0
  check / 200 || rc=1
  check /grafana/ 200 301 302 || rc=1
  [ $rc = 0 ] && echo "== Rollback OK" || echo "== Rollback: Health-Check FEHLGESCHLAGEN, bitte manuell pruefen"
  return $rc
}
'@ + "`n"
