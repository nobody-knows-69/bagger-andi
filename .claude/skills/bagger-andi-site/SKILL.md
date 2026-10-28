---
name: bagger-andi-site
description: Change, deploy or roll back the Bagger-Andi website (Michaelis Haus-, Garten- & Bauservice) hosted on NAS2 behind the nginx-funnel gateway. Use for any edit to the site's text, images, gallery, services or Impressum, for "deploy/upload/publish the site", for rollback, and for questions about where the site runs.
---

# Bagger-Andi website workflow

The site runs on NAS2 at `https://gzone.myds.me:8443/bagger-andi/`. GitHub Pages only redirects there.
Full background: `README.md` and `MEMORY.md` in this folder.

## Files – get this right

- **`index2.html` = the real site. Make every content change here.**
- `index.html` and `404.html` = GitHub Pages redirect only. **Never edit them or copy index2.html over them.**
- Media (`pic*.jpg/jpeg`, `bagger-andi.mp4`, `neue pic/ani.png`) live next to `index2.html` and are referenced relatively.

## Making a change

1. Edit `index2.html`. New images go into this folder; reference them relatively (`<img src="pic048.jpg">`). Strip GPS EXIF from new photos and blur licence plates (see MEMORY.md, Session 5).
2. Deploy to the NAS (backup → upload → health checks → auto-rollback on failure):
   ```powershell
   & D:\LOS\BaggerAndi\deploy-nas.ps1 -SiteOnly
   ```
   Use the full deploy (without `-SiteOnly`) only when the gateway files in `D:\LOS\ext_use` changed.
3. Report the health-check result to the user. If it says "Rollback wurde ausgefuehrt", the site is back on the previous state; find the cause before retrying.
4. Commit `index2.html` (+ new media) and push to `main`, but only when the user asked to save/commit. Pushing does not change the live site (that comes from the NAS).

## Adding a batch of new photos

Follow "Photo workflow (convention)" in MEMORY.md. In short: contact sheet → sort into tabs (Tiefbau / Terrassen & Pflaster / Garten & Service) → drop private or foreign images → check GPS, pixelate plates/house numbers/street signs and verify on a crop → rename to the next free `picNNN.jpg` grouped by tab → describe each in MEMORY.md → **show the user the proposed picks and wait for their choice** → add `.gal-item` cards to `index2.html` → preview via a local `python -m http.server` → `deploy-nas.ps1 -SiteOnly`.

## Rollback

```powershell
& D:\LOS\BaggerAndi\rollback-nas.ps1            # state before the last deploy
& D:\LOS\BaggerAndi\rollback-nas.ps1 -List
& D:\LOS\BaggerAndi\rollback-nas.ps1 -Backup <ts>
```

## Rules

- The sudo password comes only from the Windows keyring (`NAS2-sudo`) via `nas-lib.ps1`. Never ask for it, print it, or put it in files. If the credential is missing or sudo fails, ask the user to run `.\nas-set-cred.ps1` themselves.
- Never use `echo x | S tee` in remote scripts (S consumes stdin for the password); use `Swrite file text`.
- The site's CSP allows only self, inline scripts/styles and Google Fonts. Adding another external resource (maps, analytics, embeds) also needs a change to the CSP in `D:\LOS\ext_use\nginx.conf` and a full deploy.
- Ask before anything that changes the NAS beyond the site (firewall, DSM settings, other containers).
