# Bagger-Andi Website – Project Memory

Last updated: 2026-10-28

---

## Project Overview

**Client:** Haus-, Garten- & Bauservice Michaelis (aka „Bagger-Andi")
**Type:** Static single-page website
**Phone:** 0157 / 86841833
**Live URL (since 2026-10-28):** https://gzone.myds.me:8443/bagger-andi/ (NAS2, test operation, IPv6 only)
**Old URL:** https://nobody-knows-69.github.io/bagger-andi/ → redirects to the NAS
**GitHub Repo:** https://github.com/nobody-knows-69/bagger-andi (public; README.md = how-to)
**Claude skill:** `.claude/skills/bagger-andi-site/SKILL.md` (edit/deploy/rollback workflow)

---

## Session History

### Session 1 – Initial build
- Read `firmenprofil_bilder-1.pdf` (19.9 MB, 46 pages) to extract service descriptions, standards (DIN/VOB/DWA/LAGA/KrWG), phone number, and branding
- Created a Google Sites prompt for the company
- Executed the prompt → built `index.html` (first version: top nav, amber color scheme, tabbed gallery with emoji placeholders)
- User feedback: *"very 1980s style"* → full redesign with:
  - Fixed left sidebar (260px), dark theme `#0E1014`, amber `#D4890A`
  - Rounded corners, pill-tag service layout, CSS `columns` masonry gallery
  - `IntersectionObserver` for scroll-aware active nav highlighting
  - Mobile hamburger + overlay, fully responsive at 820px and 480px

### Session 2 – Real photos + Impressum
- Listed directory: found 20 JPEG photos (WhatsApp) + 2 MP4 videos
- Read and categorized all 20 photos into 3 gallery tabs
- Rewrote `index2.html` (primary working file) with all real photos
- Created `impressum.html` (standalone, later made redundant)
- **Integrated Impressum into `index2.html`** as a slide-in right panel overlay
  - Triggered by footer link + sidebar nav ("Rechtliches" section)
  - Close via ✕ button, click outside, or `Escape` key
  - All content has `[PLATZHALTER]` badges for missing legal data

### Session 3 – WIP Banner + GitHub Pages
- Added fixed WIP banner at top of page (German text, amber stripes, pulsing dots)
- Deployed to **GitHub Pages**: repo `nobody-knows-69/bagger-andi` (public)
- `index2.html` copied to `index.html` for Pages entry point
- `.gitignore` excludes: PDF, raw videos, index2.html, index.txt, index.pdf, .claude/

### Session 4 – MEMORY.md created
- Created `MEMORY.md` to persist project context across sessions

### Session 5 – Major content + image overhaul (2026-03-05 / 03-06)
- **Image rename**: All 47 images renamed from WhatsApp/PXL/Screenshot filenames → `pic001.jpeg` – `pic047.jpg` (standard format); all 36 HTML references updated
- **GPS metadata stripped** from 21 images (piexif); 26 had no EXIF
- **License plate blurred**: `pic018.jpeg` — "P-AM 880" pixelated at region (340,865)-(555,920) with 10× pixelation via Pillow
- **Logo comparison**: `neue pic/ani.png` (625×846 cartoon mascot on excavator, orange bg) chosen over `neue pic/micha.png` (210×235 blurry vehicle)
- **GaLaBau tile image**: Changed from `pic011.jpeg` → `pic006.jpeg`
- **Trust stats**: "4 Leistungsbereiche" → **"5 Leistungsbereiche"**
- **Photo strips**: Swapped background images strip 1 ↔ strip 3; then set strip 1 (Tiefbau) to `pic045.jpg`
- **GaLaBau modal tag**: Added `🟩 Rollrasen Verlegung`
- **Gallery expanded**: From 20 → 31 items; added 8 new cards from pics 024–047 across all 3 tabs + 3 pic039 cards in Garten & Service

### Session 6 – Video lightbox + service restructure (2026-03-06)
- **Click-to-play video**: Mascot image (`neue pic/ani.png`) is now clickable → opens fullscreen dark overlay modal playing `bagger-andi.mp4`; close via ✕, backdrop click, or Escape
  - `bagger-andi.mp4` (12MB) committed to repo (`.gitignore` has `!bagger-andi.mp4` exception)
- **Wasserbau tile removed**: All 7 Wasserbau & Gewässerunterhaltung services merged into Erdarbeiten & Tiefbau modal tags; Wasserbau photo strip (pic017) removed; dropdown option removed; `SVC_DATA.wasserbau` deleted
- **Safari mobile menu fix** (3 root causes fixed):
  1. `-webkit-appearance: none` on `.hbg` button (Safari forced system button style suppressing flex)
  2. `margin-bottom: 5px` fallback on `.hbg span` (gap unsupported in Safari < 14.1)
  3. `.wip-banner { white-space: nowrap }` on mobile (banner was wrapping to 2 lines, covering mob-bar via z-index)
  - Also fixed `inset: 0` → explicit `top/left/right/bottom` on overlay; added `-webkit-backdrop-filter`
- **Phone icon removed** from mobile top bar (📞 button + `.mob-phone` CSS deleted)

### Session 7 – Move to NAS, security, new photos (2026-10-28)
- **NAS hosting**: site runs as container `bagger-andi` behind the existing gateway `nginx-funnel` on NAS2 (details: "Migration" sections below). Tile added to the NAS landing page.
- **Keyring + scripts**: sudo password in Windows keyring (`NAS2-sudo`); `deploy-nas.ps1` (backup → checks → auto-rollback), `rollback-nas.ps1`, `nas-lib.ps1`, `nas-set-cred.ps1`, `nas-check.ps1`. Auto-rollback was tested for real twice (once on purpose, once by a real `-SiteOnly` bug, now fixed).
- **Security**: audit, gateway hardened (nginx 1.30, read-only, cap_drop, headers, rate limits), file permissions tightened, Seller Hub stopped, DSM firewall enabled (final deny still missing; FritzBox only forwards 8443).
- **GitHub Pages → redirect**: `index.html`/`404.html` forward to the NAS; the real site is `index2.html` (now tracked in git).
- **Docs**: README.md + project skill added; gateway repo `ext_use` merged to `master`.
- **New photos**: 35 WhatsApp photos from `neue pic2/` checked; 32 renamed to `pic048`–`pic079` (numbered by gallery tab), plates/house numbers pixelated, 3 private/foreign images left out. 11 added to the gallery (048, 049, 054 | 058, 055, 066, 069, 062 | 078, 079, 077) → 42 cards, deployed and verified on the NAS.

### Photo workflow (convention, use for future batches)
1. Contact sheet of the new folder; sort each photo into a gallery tab; drop private/foreign images (documents, screenshots, unrelated items).
2. Privacy: check GPS EXIF (strip if present), pixelate licence plates, house numbers, street signs; verify the pixelation on a crop.
3. Rename to the next free `picNNN.jpg` (3 digits, continuing the sequence), numbered **grouped by tab** (Tiefbau → Terrassen & Pflaster → Garten & Service). Keep originals in the source folder plus `_zuordnung_*.json` and `_uebersicht_*.jpg`.
4. Add a one-line description per photo to the File Structure list below.
5. Propose the best picks, show the user, add the chosen ones as `.gal-item` cards in `index2.html` (caption style: `<strong>Titel – Detail</strong>` + one factual sentence), preview locally, `deploy-nas.ps1 -SiteOnly`.

---

## File Structure

```
D:\LOS\BaggerAndi\
├── index2.html              ← THE SITE (edit here; tracked in git; deployed to the NAS as index.html)
├── index.html, 404.html     ← GitHub Pages redirect to the NAS only. Never overwrite with the site!
├── README.md                ← How-to for humans
├── MEMORY.md                ← This file
├── deploy-nas.ps1, rollback-nas.ps1, nas-lib.ps1, nas-set-cred.ps1, nas-check.ps1  ← NAS scripts
├── .claude/skills/bagger-andi-site/  ← Claude skill (only .claude/skills is tracked)
├── bagger-andi.mp4          ← Hero video (12MB, committed via !exception in .gitignore)
├── .gitignore
├── firmenprofil_bilder-1.pdf  (excluded from git, 19.9MB)
├── neue pic/
│   ├── ani.png              ← Company mascot logo (625×846, preferred)
│   └── micha.png            ← Alternative logo (excluded from git)
├── pic001.jpeg  ← Granitbordstein Gehrung
├── pic002.jpeg  ← Sportanlage Unterbau (Tiefbau)
├── pic003.jpeg  ← Tragschichtmaterial (Tiefbau)
├── pic004.jpeg  ← Verdichtung Walze (Tiefbau)
├── pic005.jpeg  ← Muttererde (Garten)
├── pic006.jpeg  ← Terrasse + Glasschiebetür
├── pic007.jpeg  ← Linienentwässerung
├── pic008.jpeg  ← Feinsteinzeug Detail
├── pic009.jpeg  ← Terrasse fertig bodengleich
├── pic010.jpeg  ← Terrassenrand Detail
├── pic011.jpeg  ← Luftaufnahme Terrasse
├── pic012.jpeg  ← Rasengittersteine
├── pic013.jpeg  ← Baumstamm Abtransport (Garten)
├── pic014.jpeg  ← Versetzarbeiten Mobilkran (Garten)
├── pic015.jpeg  ← Grünschnitt (Garten)
├── pic016.jpeg  ← Tiefe Baugrube (Tiefbau)
├── pic017.jpeg  ← Wasserbau/Graben (was strip 3 bg; still in repo)
├── pic018.jpeg  ← Winterdienst (license plate BLURRED)
├── pic019.jpeg  ← Erdbau/Tiefbau tile
├── pic020.jpeg  ← (was Wasserbau tile; still in repo)
├── pic021.jpeg  ← (unnumbered base)
├── pic022.jpeg  ← (unnumbered base)
├── pic023.jpeg  ← (unnumbered)
├── pic024.jpg – pic047.jpg  ← New batch: garden, rollrasen, pool, retaining walls
│   Notable: pic039.jpg = Rollrasen verlegen (used in 3 Garten gallery cards)
│            pic045.jpg = Pool/Teich excavation (strip 1 Tiefbau background)
├── pic048.jpg – pic079.jpg  ← Batch 2026-10-24 (from `neue pic2/`, renamed 2026-10-28), numbered by gallery tab:
│   Tiefbau & Kanalbau:
│     048 Leitungsgraben mit Rüttelstampfer · 049 Graben an Hauswand, Bagger · 050 Aushub am Zaun
│     051 Planum Freifläche · 052 Planum Waldgrundstück · 053 Transporter + Anhänger Kiesgrube · 054 Kipper beim Abladen
│   Terrassen & Pflaster:
│     055 Hof Betonpflaster + Entwässerungsrinne (Hausnr. verpixelt) · 056 Pflaster am Zaun · 057 Vorgarten Pflaster + Stufe (Hausnr./Straße verpixelt)
│     058/059/060 Terrasse Großformat hell (fertig) · 061 Großformat Verlegung in Arbeit · 062 Terrasse in Arbeit mit Laser
│     063 Plattenweg am Haus · 064 Terrassenplatten + Kiesrinne · 065 Plattenweg + neuer Rasen
│     066 große Hoffläche Betonpflaster · 067 Pflaster Detail · 068 Terrasse am Holzlager · 069 Einfahrt mit Kiesstreifen (2 Kennzeichen verpixelt)
│     070–075 Fischgrätpflaster mit Schacht (frisch verfugt, Zementschleier)
│   Garten & Service:
│     076 neuer Rasen · 077 Wärmepumpen-Fundament Kiesbett · 078/079 Eingangsstufe vorher/nachher (Granit)
│   Not used (left in `neue pic2/`): Brief mit Beträgen (privat), TV-Karton, Google-Maps-Screenshot Fremdfirma, 1 Video
│   Mapping original WhatsApp name → picNNN: `neue pic2/_zuordnung_pic048-079.json`; overview sheet `neue pic2/_uebersicht_pic048-079.jpg`
└── WhatsApp Video 2026-02-26 at 17.11.37 (1).mp4  (excluded from git)
```

---

## Services (SVC_DATA keys)

| Key | Name | Tile image |
|-----|------|-----------|
| `erdbau` | Erdarbeiten & Tiefbau | pic019.jpeg |
| `galabau` | Garten- & Landschaftsbau | pic006.jpeg |
| `abbruch` | Abbruch & Rückbau | pic014.jpeg |
| `winterdienst` | Winterdienst | pic018.jpeg |

> Wasserbau was removed – all 7 tags merged into `erdbau`.

---

## Gallery Structure

**Tab 1 – Tiefbau & Kanalbau** (`g-tiefbau`): 9 items (new 2026-10-28: pic048, pic049, pic054)
**Tab 2 – Terrassen & Pflaster** (`g-terrassen`): 19 items (new: pic058, pic055, pic066, pic069, pic062)
**Tab 3 – Garten & Service** (`g-garten`): 14 items (new: pic078 vorher, pic079 nachher, pic077)
**Total: 42 gallery cards** (CSS columns masonry: new cards appear spread across the columns, not at the end)

---

## Photo Strips (top-to-bottom order)

| Strip | Pill | Background | Layout |
|-------|------|-----------|--------|
| 1 | 🏗️ Erdarbeiten & Tiefbau | `pic045.jpg` | left |
| 2 | 🌿 Garten- & Landschaftsbau | `pic011.jpeg` | right |
| 3 | ❄️ Winterdienst | `pic018.jpeg` | right |
| 4 | 🔨 Abbruch & Rückbau | `pic014.jpeg` | left |

---

## Design System

| Token | Value | Usage |
|---|---|---|
| `--amber` | `#D4890A` | Primary accent |
| `--amber-l` | `#F5A623` | Hover / highlight |
| `--amber-glow` | `rgba(212,137,10,.14)` | Backgrounds, glows |
| `--dark` | `#0E1014` | Page background |
| `--surface` | `#161920` | Sidebar, cards |
| `--surface2` | `#1C2029` | Nested cards |
| `--text` | `#EAEAF0` | Body text |
| `--muted` | `#7E8399` | Secondary text |
| `--border` | `rgba(255,255,255,.07)` | Card borders |
| `--sw` | `270px` | Sidebar width |
| `--r` | `20px` | Card border radius |
| `--r-sm` | `12px` | Small radius |

**Font:** Inter (Google Fonts)
**Breakpoints:** 820px (mobile sidebar), 480px (small mobile)

---

## Key JS Functions

| Function | Purpose |
|---|---|
| `toggleSB()` | Open/close mobile sidebar |
| `closeSB()` | Close sidebar (called on nav link click) |
| `showG(id, btn)` | Switch gallery tab |
| `showImpressum()` | Open impressum slide-in panel |
| `closeImpressum()` | Close impressum panel |
| `openSvcModal(key)` | Open service detail modal (uses SVC_DATA) |
| `closeSvcModal()` | Close service modal |
| `closeVideo()` | Close video lightbox + pause/reset video |
| `handleForm(e)` | Contact form submission (alert placeholder) |
| `IntersectionObserver` | Highlight active nav item on scroll |

---

## Pending / To-Do

- [ ] Fill in `[PLATZHALTER]` fields in Impressum (address, name, email, Steuernummer, Gewerbeamt, hosting details)
- [ ] Wire up contact form to real email (Formspree.io or similar, free tier)
- [ ] Remove WIP banner when site goes live
- [ ] Set up **Google Business Profile** (biggest SEO lever for local trades)
- [ ] Optional: connect custom domain (e.g. `bagger-andi.de`) to GitHub Pages
- [ ] Optional: add `LocalBusiness` JSON-LD schema markup for SEO
- [ ] Optional: use `neue pic/ani.png` as favicon or og:image
- [ ] Optional: embed Google Maps in Kontakt section

---

## Deployment

**How to update the live site (since 2026-10-28: NAS, not GitHub Pages):**
```bash
# Edit index2.html (the real site, now tracked in git), then:
powershell -ExecutionPolicy Bypass -File D:\LOS\BaggerAndi\deploy-nas.ps1 -SiteOnly
git add index2.html && git commit -m "describe your change" && git push
```
- **Do NOT copy index2.html over index.html any more.** `index.html` + `404.html` are the GitHub Pages redirect to `https://gzone.myds.me:8443/bagger-andi/`. `deploy-nas.ps1` refuses a redirect page as source.
- Undo the redirect: `git revert <redirect commit>` + push (Pages updates in ~2 min).
- `-SiteOnly` restarts the bagger-andi container (bind mount would otherwise point at the deleted old folder).

**GitHub CLI location:** `"C:\Program Files\GitHub CLI\gh.exe"`
**CDN cache:** After push, hard-reload with `Ctrl+Shift+R` if changes aren't visible

---

## SEO Notes

- Google Sites gives **no automatic SEO boost**
- **Google Business Profile** (`business.google.com`) → highest ROI for local trades
- List on: Gelbe Seiten, Das Örtliche, local trade directories
- Link all listings to the GitHub Pages URL
- Keywords to target: "Baggerarbeiten [Stadt]", "Tiefbau [Region]", "Terrassenbau [Region]"

---

## Migration: GitHub Pages -> private NAS (planned, 2026-10-28)

### Goal
Host the site on the private local NAS (**https://192.168.165.73/**), behind the nginx reverse proxy that already runs there (same pattern as the Grafana dashboard). React framework requested. No fixed public IP needed (DDNS or Cloudflare Tunnel instead). Secrets must come from the OS keyring, never from files or prompts.
This is NOT one of the QNAPs from the QNAP data migration (192.168.178.99 / .100).

### Verified facts
- Site today: static single page, `index.html` (79 KB, identical to `index2.html`), no build system.
- Referenced media: 30 files, **86.7 MB** in total. `pic024`-`pic044` are 6-8 MB each.
- Fonts: Inter loaded from Google Fonts (GDPR issue, host locally).
- Contact form (`handleForm`) is only an `alert` placeholder, sends nothing.
- Uncommitted: `MEMORY.md`, `index2_v2_backup.html`, two screenshots, `neue pic/IMG-*`.
- `.gitignore` now also excludes `nas-info.txt` and `nas-check.ps1`.

### Verified on NAS2 (2026-10-28, local session)
- Synology DSM, x86_64, 3.9 GB RAM (~2 GB available). SSH key login as `gman` works.
- nginx on 80/443 is **DSM's own system nginx** (`/etc/nginx/nginx.conf.run`), not a container.
- Docker is at `/usr/local/bin/docker` (not on non-interactive PATH) and needs sudo.
- DSM 7.1.1-42962, volume1 4.5 TB (1.2 TB used). `gman` is in `administrators`.
- sudo password lives in Windows keyring as generic credential `NAS2-sudo` (save with `.\nas-set-cred.ps1`; `cmdkey /pass` stored it empty). `.\nas-check.ps1` reads it and writes read-only results to `nas-info.txt`. Gotcha: .NET prepends a UTF-8 BOM to ssh stdin, the remote script strips it.
- Compose: only `docker-compose` v1.28.5 (no `docker compose` v2).

### Gateway already exists (test setup, found 2026-10-28)
- Public entry: **`https://gzone.myds.me:8443/`** (Synology DDNS). DSM reverse-proxy rule (`sites-enabled/server.ReverseProxy.conf`): `gzone.myds.me:8443` → `http://127.0.0.1:8080`.
- `nginx-funnel` container (`nginx:1.27-alpine`, `127.0.0.1:8080->80`). Config + landing page are bind mounts: `/volume1/docker/ext_use/nginx.conf` and `/volume1/docker/ext_use/index.html` (not in git).
  - `= /` → static `index.html` (strict CSP `default-src 'none'`, so no JS; a React portal needs a CSP change)
  - `/grafana/` → `http://192.168.165.73:3001` (`grafana-subpath` container, `GF_SERVER_SERVE_FROM_SUB_PATH=true`)
  - everything else → 404
- Gaps: apps are reached via host IP + published port (3001 is open on the whole LAN, bypassing the gateway); all containers sit on the default `bridge` (an unused `ext_use_default` network exists); no auth at the gateway.
- Other containers: grafana :3000, influxdb1 :8086, seller-support-hub :8000/:8501, passbolt :8766/:8767, e3dc-writer, docker-monitor.

### Bagger-Andi deployed behind the gateway (2026-10-28)
- Live (test): `https://gzone.myds.me:8443/bagger-andi/`, tile added to the landing page. Verified end-to-end through DSM nginx.
- Gateway source = repo `D:\LOS\ext_use` (GitHub `nobody-knows-69/ext_use`); changes there are **uncommitted**.
  - `nginx-funnel` + `bagger-andi` now run via `docker-compose` in `/volume1/docker/ext_use` (network `ext_use_default`). Before, `nginx-funnel` was a plain `docker run` container.
  - `/bagger-andi/` route uses `resolver 127.0.0.11` + variable, so the gateway still starts if bagger-andi is down. `absolute_redirect off` keeps redirects on :8443.
  - bagger-andi container: `nginx:1.27-alpine`, no published port, content in `/volume1/docker/bagger-andi/site`.
- Scripts in this repo (all use `nas-lib.ps1` → keyring sudo):
  - `.\deploy-nas.ps1` (backup → upload to staging → `nginx -t` + compose check → switch → 7 health checks → **auto-rollback** on failure). `-SiteOnly` updates only the website files.
  - `.\rollback-nas.ps1` (latest backup) / `-List` / `-Backup <ts>`. Backups in `/volume1/docker/ext_use/backups/<ts>/`. Rollback tested successfully 2026-10-28.
  - Backup `20261028-192433` = original state before any change (nginx-funnel via docker run, no Bagger-Andi).
- Gotcha: never `echo x | S tee file` in remote scripts (S uses stdin for the password); use `Swrite file text`.

### Security audit (2026-10-28)
- OK: TLS 1.3 + valid LE cert (until 2027-01-18), TLS 1.0/1.1 refused; DSM rule answers only for `gzone.myds.me`; gateway blocks path traversal, POST, dotfiles; Grafana 12.3.2 + InfluxDB need auth; SSH key-only.
- Done: `seller-support-hub` stopped, restart policy set to `no` (container + `/volume1/docker/leads/data` kept; restart with `docker start seller-support-hub`).
- Router = **FritzBox**, forwards only 8443 to the NAS (user, 2026-10-28). Phone on mobile data: 8443 works (via IPv6), 5001 blocked by the FritzBox.
- DSM firewall **enabled** 2026-10-28 with 5 allow rules (LAN `192.168.165.0/24`, `fdc4:6071:67d1::/64`, `2003:d2:5f21:a500::/64`, TCP 8443, TCP 80), but the **final deny is NOT active** (no 6th rule saved, "if no rules match" still allow), so it blocks nothing yet. To do: add "Alle/Alle/Verweigern" as last rule or set deny per interface (LAN 1), then click "Übernehmen".
  - Caveat: rule 3 uses the public Telekom IPv6 prefix, which can change on reconnect; update it then.
- Auto-block on (10 tries / 5 min, permanent), allow list `192.168.165.0-254` (+ IPv6 subnets suggested). DoS protection on LAN 1 enabled.
- Open, by priority:
  1. NAS firewall final deny (see above) + FritzBox: disable "Selbstständige Portfreigaben" (UPnP) for the NAS.
  2. Docker ports on `0.0.0.0` bypass the DSM firewall (Grafana 3000/3001, Influx 8086, Passbolt 8766/8767). Move `grafana-subpath` onto `ext_use_default`, drop 3001; bind others to `192.168.165.73`.
  3. Updates: `nginx:1.27-alpine` 18 months old (internet-facing), DSM 7.1.1 U9 (Jul 2025), grafana/influx images 8-9 months.
  4. ~~Permissions~~ **Done 2026-10-28**: only 3 Linux-mode files were really world-writable (777): `.env` → 600, `docker-compose.yml` → 644, `setup-grafana-key.sh` → 700. Other files are under Synology ACLs (everyone read, admins/gman write) and were left alone (no secrets). Rollback: `.\rollback-nas.ps1 -Perms 20261028-202810`. Leftover junk files `D:\LOS\ext_use\Caddyfile` / `...docker-compose.yml` in that folder (from an old scp).
  - IPv4 for `gzone.myds.me`: not possible, Synology DDNS doesn't support it here (user, 2026-10-28). The site is reachable over IPv6 only.
  5. `docker-monitor` mounts docker.sock rw (= root), no ports.
  6. ~~Gateway containers~~ **Done 2026-10-28** (backup `20261028-201608` = state before): both on `nginx:1.30-alpine`, read-only rootfs + tmpfs, `cap_drop ALL` (+CHOWN/SETUID/SETGID/NET_BIND_SERVICE), `no-new-privileges`; HSTS/CSP/nosniff/frame headers; real client IP via `X-Real-IP` from DSM; rate limits 30 r/s per IP (burst 20/100/200) and `/grafana/login` 10 r/min (burst 10). Verified: 32 parallel page files → all 200, login limit → 429 after 10.
  - Not checked: default `admin` account disabled?, DSM auto-block, 2FA.

### Still open
- Is port 8443 forwarded on the router? Test `https://gzone.myds.me:8443/` from outside (phone on mobile data).

### Target architecture (decided 2026-10-28)
- **DSM nginx = the only outside entry** (TLS via DSM). The DSM rule `gzone.myds.me:8443` → `127.0.0.1:8080` already exists.
- **Gateway container** = existing `nginx-funnel` (move its config into git) does path routing: `/` → portal, `/grafana/`, `/bagger-andi/`, `/<app>/`.
- Bagger-Andi target URL: `https://gzone.myds.me:8443/bagger-andi/` (also the GitHub Pages redirect target).
- **Portal** = React landing page with an app icon per app. Every new app = a React container on an internal Docker network (no published ports) + one gateway snippet + one portal entry.
- Path-based (one URL); subdomain only for apps that can't run under a subpath.
- Portal + Grafana behind a login; `/bagger-andi/` stays public for testers.
- Status: **test project only**, not officially live. Own domain for Bagger-Andi deferred until go-live.

### GitHub Pages redirect (final step)
- Replace `index.html` (+ `404.html`) on GitHub Pages with meta-refresh + `location.replace` to the new NAS URL, so current testers don't need the new address.
- Only after the NAS URL is publicly reachable and checked from outside the home network. Push only on the user's explicit go-ahead.

### Plan
1. **Images**: convert the 21 large photos to WebP, max 1920 px (target about 8 MB total instead of 86.7 MB).
2. **Fonts + form**: self-host Inter; connect the contact form to a mail forwarder.
3. **React shell**: Vite + React, content split into components. Alternative without React: serve `index.html` directly with nginx (saves about one day).
4. **Container**: multi-stage Dockerfile (`node:22-alpine` build, `nginx:alpine` serve), Compose file, bound to `127.0.0.1:8081`.
5. **Reverse proxy**: new server block in the existing nginx, own subdomain (`base: '/'`; a subpath would need `base` and `basename` changes).
6. **Deploy**: GitHub Actions builds the image and pushes it to GHCR; the NAS pulls it (Watchtower or SSH `compose pull && up -d`).
7. **Cutover**: lower DNS TTL to 300 s a day before, test on a test subdomain, switch DNS, keep GitHub Pages 7 days, then switch it off.

### Risks
- A NAS on a home line means power cuts, router reboots and limited upload; municipalities are the target audience, so downtime looks bad. Cloudflare Tunnel avoids port forwarding and adds CDN and DDoS protection.
- Opening port 443 to the internet needs rate limiting or Fail2ban, a current nginx and a separate Docker network.
- Existing pending items (Impressum placeholders, WIP banner, Google Business Profile) are unchanged and still open.
