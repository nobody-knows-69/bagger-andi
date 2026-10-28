# Speichert das sudo-Passwort fuer NAS2 im Windows-Schluesselbund (generic credential "NAS2-sudo").
# Aufruf (selbst ausfuehren, fragt verdeckt nach dem Passwort): .\nas-set-cred.ps1
param([string]$User = "gman", [string]$CredTarget = "NAS2-sudo")

Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public class NasCredWrite {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  struct CREDENTIAL { public int Flags; public int Type; public string TargetName; public string Comment;
    public long LastWritten; public int CredentialBlobSize; public IntPtr CredentialBlob; public int Persist;
    public int AttributeCount; public IntPtr Attributes; public string TargetAlias; public string UserName; }
  [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
  static extern bool CredWrite(ref CREDENTIAL cred, int flags);
  public static bool Save(string target, string user, string pw) {
    var c = new CREDENTIAL { Type = 1, TargetName = target, UserName = user, Persist = 2,   // GENERIC, LOCAL_MACHINE
      CredentialBlobSize = pw.Length * 2, CredentialBlob = Marshal.StringToCoTaskMemUni(pw) };
    try { return CredWrite(ref c, 0); } finally { Marshal.ZeroFreeCoTaskMemUnicode(c.CredentialBlob); }
  }
}
'@
function Read-Pw($prompt) {
  $s = Read-Host $prompt -AsSecureString
  [Runtime.InteropServices.Marshal]::PtrToStringUni([Runtime.InteropServices.Marshal]::SecureStringToBSTR($s))
}
$pw  = Read-Pw "sudo-Passwort fuer $User auf NAS2"
$pw2 = Read-Pw "Passwort wiederholen"
if (-not $pw) { Write-Error "Leeres Passwort, nichts gespeichert."; exit 1 }
if ($pw -cne $pw2) { Write-Error "Eingaben stimmen nicht ueberein, nichts gespeichert."; exit 1 }
Remove-Variable pw2
if ([NasCredWrite]::Save($CredTarget, $User, $pw)) { Write-Host "Gespeichert als '$CredTarget' (Benutzer $User)." } else { Write-Error "CredWrite fehlgeschlagen." }
Remove-Variable pw
