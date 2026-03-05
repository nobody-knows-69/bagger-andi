# Bagger-Andi Website – Project Memory

Last updated: 2026-03-03

---

## Project Overview

**Client:** Haus-, Garten- & Bauservice Michaelis (aka „Bagger-Andi")
**Type:** Static single-page website
**Phone:** 0157 / 86841833
**Live URL:** https://nobody-knows-69.github.io/bagger-andi/
**GitHub Repo:** https://github.com/nobody-knows-69/bagger-andi

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
- Read and categorized all 20 photos into 3 gallery tabs:
  - **Tiefbau & Kanalbau (5):** (2)(3)(4)(16)(17).jpeg
  - **Terrassen & Pflaster (10):** 17.11.30, 17.11.31, (1)(6)(7)(8)(9)(10)(11)(12).jpeg
  - **Garten & Service (5):** (5)(13)(14)(15)(18).jpeg
- Rewrote `index2.html` (primary working file) with all real photos, URL-encoded filenames
- Created `impressum.html` (standalone, later made redundant)
- **Integrated Impressum into `index2.html`** as a slide-in right panel overlay
  - Triggered by footer link + sidebar nav ("Rechtliches" section)
  - Close via ✕ button, click outside, or `Escape` key
  - All content has `[PLATZHALTER]` badges for missing legal data

### Session 3 – WIP Banner + GitHub Pages
- Added fixed WIP banner at top of page:
  - German text: *"🚧 Diese Seite befindet sich noch im Aufbau – Testversion, keine offizielle Veröffentlichung"*
  - Amber diagonal stripe background, pulsing dots animation
  - Sidebar/mobile bar shifted down 30px to accommodate
- Deployed to **GitHub Pages**:
  - Repo: `nobody-knows-69/bagger-andi` (public)
  - `index2.html` copied to `index.html` for Pages entry point
  - `.gitignore` excludes: PDF, videos, index2.html, index.txt, index.pdf, .claude/
  - 23 files committed: index.html, impressum.html, .gitignore, 20 JPEGs
- Discussed SEO: Google Business Profile is the biggest traffic driver for local trades, not Google Sites

### Session 4 – This file
- Created `MEMORY.md` to persist project context across sessions

---

## File Structure

```
D:\LOS\BaggerAndi\
├── index.html               ← GitHub Pages entry (copy of index2.html)
├── index2.html              ← PRIMARY WORKING FILE
├── impressum.html           ← Standalone impressum (backup; integrated into index2.html)
├── MEMORY.md                ← This file
├── .gitignore
├── firmenprofil_bilder-1.pdf  (excluded from git, 19.9MB)
├── WhatsApp Image 2026-02-26 at 17.11.30.jpeg
├── WhatsApp Image 2026-02-26 at 17.11.31.jpeg
├── WhatsApp Image 2026-02-26 at 17.11.31 (1).jpeg   ← Granitbordstein Gehrung
├── WhatsApp Image 2026-02-26 at 17.11.31 (2).jpeg   ← Sportanlage Unterbau (Tiefbau)
├── WhatsApp Image 2026-02-26 at 17.11.31 (3).jpeg   ← Tragschichtmaterial (Tiefbau)
├── WhatsApp Image 2026-02-26 at 17.11.31 (4).jpeg   ← Verdichtung Walze (Tiefbau)
├── WhatsApp Image 2026-02-26 at 17.11.31 (5).jpeg   ← Muttererde (Garten)
├── WhatsApp Image 2026-02-26 at 17.11.31 (6).jpeg   ← Terrasse + Glasschiebetür
├── WhatsApp Image 2026-02-26 at 17.11.31 (7).jpeg   ← Linienentwässerung
├── WhatsApp Image 2026-02-26 at 17.11.31 (8).jpeg   ← Feinsteinzeug Detail
├── WhatsApp Image 2026-02-26 at 17.11.31 (9).jpeg   ← Terrasse fertig bodengleich
├── WhatsApp Image 2026-02-26 at 17.11.31 (10).jpeg  ← Terrassenrand Detail
├── WhatsApp Image 2026-02-26 at 17.11.31 (11).jpeg  ← Luftaufnahme Terrasse
├── WhatsApp Image 2026-02-26 at 17.11.31 (12).jpeg  ← Rasengittersteine
├── WhatsApp Image 2026-02-26 at 17.11.31 (13).jpeg  ← Baumstamm Abtransport (Garten)
├── WhatsApp Image 2026-02-26 at 17.11.31 (14).jpeg  ← Versetzarbeiten Mobilkran (Garten)
├── WhatsApp Image 2026-02-26 at 17.11.31 (15).jpeg  ← Grünschnitt (Garten)
├── WhatsApp Image 2026-02-26 at 17.11.31 (16).jpeg  ← Kanalbauarbeiten (Tiefbau)
├── WhatsApp Image 2026-02-26 at 17.11.31 (17).jpeg  ← Tiefe Baugrube (Tiefbau)
├── WhatsApp Image 2026-02-26 at 17.11.31 (18).jpeg  ← Winterdienst (Garten)
├── WhatsApp Video 2026-02-26 at 17.11.37.mp4         (excluded from git)
└── WhatsApp Video 2026-02-26 at 17.11.37 (1).mp4    (excluded from git)
```

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
| `handleForm(e)` | Contact form submission (alert placeholder) |
| `IntersectionObserver` | Highlight active nav item on scroll |

---

## Pending / To-Do

- [ ] Fill in `[PLATZHALTER]` fields in Impressum (address, name, email, Steuernummer, Gewerbeamt, hosting details)
- [ ] Set up **Google Business Profile** (biggest SEO lever for local trades)
- [ ] Optional: connect custom domain (e.g. `bagger-andi.de`) to GitHub Pages
- [ ] Optional: add `LocalBusiness` JSON-LD schema markup for SEO
- [ ] Optional: embed Google Maps in Kontakt section
- [ ] Optional: wire up contact form to real email (Formspree.io or similar, free tier)
- [ ] Optional: add 2 MP4 videos to gallery when ready
- [ ] Remove WIP banner when site goes live

---

## Deployment

**How to update the live site:**
```bash
# Edit index2.html locally, then:
cp index2.html index.html
cd D:/LOS/BaggerAndi
git add index.html
git commit -m "describe your change"
git push
# GitHub Pages auto-deploys in ~30 seconds
```

**GitHub CLI location:** `"C:\Program Files\GitHub CLI\gh.exe"`

---

## SEO Notes (discussed)

- Google Sites gives **no automatic SEO boost**
- **Google Business Profile** (`business.google.com`) → highest ROI for local trades
- List on: Gelbe Seiten, Das Örtliche, local trade directories
- Link all listings to the GitHub Pages URL
- Keywords to target: "Baggerarbeiten [Stadt]", "Tiefbau [Region]", "Terrassenbau [Region]"
