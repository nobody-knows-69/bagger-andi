# Read-only Pruefung von NAS2 (Synology DSM). Aufruf: .\nas-check.ps1
# SSH per Key; sudo-Passwort kommt aus dem Windows-Schluesselbund (generic credential "NAS2-sudo").
# Einmalig anlegen: .\nas-set-cred.ps1  (cmdkey /pass speichert bei generic oft ein leeres Passwort)
# Das Passwort wird nur per stdin an sudo -S weitergereicht, nie ausgegeben oder gespeichert.
param([string]$User = "gman", [string]$NasHost = "192.168.165.73", [string]$CredTarget = "NAS2-sudo")

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
$pw = [NasCred]::Get($CredTarget)
if (-not $pw) { Write-Error "Credential '$CredTarget' fehlt oder ist leer. Anlegen mit: .\nas-set-cred.ps1"; exit 1 }

$remote = @'
IFS= read -r PW
PW=${PW%$'\r'}              # PowerShell haengt CRLF an
PW=${PW#$'\xef\xbb\xbf'}     # .NET setzt ein UTF-8-BOM vor stdin
S() { printf '%s\n' "$PW" | sudo -S -p '' "$@"; }
D=/usr/local/bin/docker
echo "## system";    uname -m; grep -E '^(productversion|buildnumber)' /etc.defaults/VERSION
echo "## resources"; free -m | head -2; df -h /volume1 2>/dev/null | tail -1
echo "## sudo";      id; S true 2>&1 && echo "sudo OK" || { echo "sudo FEHLGESCHLAGEN"; exit 1; }
echo "## docker";    S $D ps --format '{{.Names}} | {{.Image}} | {{.Ports}} | {{.Status}}'
echo "## compose";   S $D compose version 2>&1 | head -1; S $D-compose version 2>&1 | head -1
echo "## networks";  S $D network ls --format '{{.Name}} {{.Driver}}'
echo "## listening"; S netstat -tlnp 2>/dev/null | awk 'NR>2{print $4, $7}' | sort -u
echo "## nginx (DSM)"; S nginx -T -c /etc/nginx/nginx.conf.run 2>/dev/null | grep -nE 'server_name|listen|proxy_pass|ssl_certificate |location' | head -150
echo "## DSM nginx: Server auf 8443 (Gateway-Eingang)"; S nginx -T -c /etc/nginx/nginx.conf.run 2>/dev/null | grep -nE '^# configuration file|listen .*8443' | grep -B1 '8443'
S nginx -T -c /etc/nginx/nginx.conf.run 2>/dev/null | awk '/listen .*8443/{f=1} f{print; if(/^}/||++n>40){f=0;n=0}}' | grep -vE '^\s*#|ssl_(ciphers|protocols|prefer)' | head -60
echo "## nginx-funnel: Mounts"; S $D inspect nginx-funnel --format '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{println}}{{end}}' 2>/dev/null
echo "## nginx-funnel: Config"; S $D exec nginx-funnel nginx -T 2>/dev/null | grep -vE '^\s*#|^\s*$' | grep -vE 'mime|types \{|^\s+[a-z]+/[a-z0-9.+-]+\s' | head -80
echo "## Netzwerke der Container"; S $D ps --format '{{.Names}}' | while read c; do printf '%s: ' "$c"; S $D inspect "$c" --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}'; done
echo "## DSM reverse proxy rules"; S cat /etc/nginx/app.d/server.ReverseProxy.conf 2>/dev/null | grep -E 'server_name|listen|proxy_pass' || echo "(keine)"
echo "## certificates (nur Namen)"; S cat /usr/syno/etc/certificate/_archive/INFO 2>/dev/null | grep -oE '"desc" *: *"[^"]*"|"subject"[^}]*' | head -20; S ls /usr/syno/etc/certificate/_archive/ 2>/dev/null
echo "## grafana server settings"; for c in $(S $D ps --format '{{.Names}}' | grep -i grafana); do echo "-- $c"; S $D inspect $c --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -E '^GF_SERVER_' ; done
'@

# PowerShell 5.1 zerlegt Anfuehrungszeichen in nativen Argumenten -> Skript base64-kodiert uebergeben.
$b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($remote -replace "`r", "")))
# Passwort direkt als Bytes an ssh-stdin schreiben (die PowerShell-Pipe veraendert den Wert).
$psi = New-Object Diagnostics.ProcessStartInfo "ssh", "-o BatchMode=yes $User@$NasHost `"bash -c 'bash <(echo $b64 | base64 -d)'`""
$psi.UseShellExecute = $false; $psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
$psi.StandardOutputEncoding = [Text.Encoding]::UTF8
$proc = [Diagnostics.Process]::Start($psi)
$bytes = (New-Object Text.UTF8Encoding $false).GetBytes($pw + "`n")
$proc.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length); $proc.StandardInput.Close()
[Array]::Clear($bytes, 0, $bytes.Length)
$out = Join-Path $PSScriptRoot "nas-info.txt"
$proc.StandardOutput.ReadToEnd() -replace "`r", "" | Tee-Object -FilePath $out
$proc.WaitForExit()
Remove-Variable pw
Write-Host "`nFertig. Ausgabe liegt in $out"
