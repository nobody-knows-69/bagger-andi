# Bagger-Andi – Website

Website für **Haus-, Garten- & Bauservice Michaelis** („Bagger-Andi"). Statische Einzelseite (HTML/CSS/JS, kein Framework).

| | |
|---|---|
| **Live (NAS2, Testbetrieb)** | https://gzone.myds.me:8443/bagger-andi/ |
| **Alte Adresse (GitHub Pages)** | https://nobody-knows-69.github.io/bagger-andi/ → leitet automatisch auf das NAS weiter |
| **NAS-Startseite** | https://gzone.myds.me:8443/ (Kachel „Bagger-Andi" neben Grafana) |

> Die Seite ist nur über **IPv6** erreichbar (Synology-DDNS hat keinen IPv4-Eintrag). Netze ohne IPv6 (manche Firmen-WLANs, Hotels) erreichen sie nicht.

## Welche Datei ist was?

| Datei | Zweck |
|---|---|
| `index2.html` | **Die echte Website.** Hier wird geändert. Wird auf das NAS kopiert (dort als `index.html`). |
| `index.html`, `404.html` | **Nur Weiterleitung** von GitHub Pages auf das NAS. Nicht überschreiben! |
| `pic*.jpg/jpeg`, `bagger-andi.mp4`, `neue pic/ani.png` | Bilder und Video der Website |
| `deploy-nas.ps1` | Website (und Gateway) auf das NAS bringen, mit Backup, Prüfung und automatischem Rollback |
| `rollback-nas.ps1` | Auf einen früheren Stand zurück |
| `nas-lib.ps1` | Gemeinsame Helfer der NAS-Skripte (SSH, sudo aus dem Schlüsselbund) |
| `nas-set-cred.ps1` | sudo-Passwort einmalig im Windows-Schlüsselbund speichern |
| `nas-check.ps1` | NAS nur lesend prüfen (Container, nginx, Ports) → `nas-info.txt` |
| `MEMORY.md` | Ausführliche Projekt-Notizen und Verlauf |

## Website ändern

1. `index2.html` bearbeiten (neue Bilder in diesen Ordner legen und in `index2.html` verlinken).
2. Optional lokal ansehen: `index2.html` im Browser öffnen.
3. Auf das NAS bringen:
   ```
   powershell -ExecutionPolicy Bypass -File D:\LOS\BaggerAndi\deploy-nas.ps1 -SiteOnly
   ```
4. Auf GitHub sichern:
   ```
   git add index2.html <neue Bilder>
   git commit -m "Was geändert wurde"
   git push
   ```

Das Deploy-Skript lädt automatisch alle Dateien hoch, die `index2.html` verwendet. Bei einem Fehler im Health-Check wird automatisch der vorherige Stand wiederhergestellt.

## Rollback

```
.\rollback-nas.ps1                    # Stand vor dem letzten Deploy
.\rollback-nas.ps1 -List              # alle Backups anzeigen
.\rollback-nas.ps1 -Backup <zeitstempel>
.\rollback-nas.ps1 -Perms <zeitstempel>   # nur Dateirechte zurücksetzen
```

Weiterleitung von GitHub Pages rückgängig machen: `git revert ecfba46` und `git push` (GitHub Pages ist nach ca. 2 Minuten aktualisiert).

## Aufbau auf dem NAS

```
Internet ──8443──► FritzBox ──► DSM-nginx (TLS, Let's Encrypt, Regel gzone.myds.me:8443 → 127.0.0.1:8080)
                                   └─► nginx-funnel (Gateway, Docker)
                                         /             → Startseite mit App-Kacheln
                                         /grafana/     → Grafana
                                         /bagger-andi/ → Container bagger-andi (kein eigener Port)
```

- Gateway-Konfiguration: Repo [`ext_use`](https://github.com/nobody-knows-69/ext_use) (lokal `D:\LOS\ext_use`), auf dem NAS in `/volume1/docker/ext_use`.
- Website-Dateien auf dem NAS: `/volume1/docker/bagger-andi/site`.
- Backups: `/volume1/docker/ext_use/backups/<zeitstempel>/`.
- Beide nginx-Container: `nginx:1.30-alpine`, read-only, minimale Rechte, Security-Header, Rate-Limits.

## Voraussetzungen (einmalig)

- SSH-Key für `gman@192.168.165.73` (NAS2).
- sudo-Passwort im Windows-Schlüsselbund: `.\nas-set-cred.ps1` (fragt zweimal verdeckt nach dem Passwort).
