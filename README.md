# Guild Wars 2 Story Tracker

A single-page web app that tracks your story journal progress across all characters on your Guild Wars 2 account and recommends which character to play next.

**Live site:** [gw2storytracker.com](https://gw2storytracker.com) | [GitHub Pages mirror](https://mattygroch.github.io/gw2-storytracker/)

## Features

- **Quest-level progress tracking** across all story seasons — from the core Personal Story through the latest expansions
- **Race-aware progress** for the Personal Story, filtering out story arcs that don't apply to each character's race
- **"Continue Your Journey" recommendation** highlighting the character and story closest to completion
- **Account summary** showing total characters, stories completed, and overall completion percentage
- **By Story / By Character views** to browse progress from either angle, with cross-view navigation (click a character to jump to their card, or click a story to jump to that season)
- **Single-character mode** — accounts with one character get a streamlined layout without the view toggle
- **Character visibility toggle** — hide characters from the Story view to focus on the ones that matter; persisted across sessions
- **Character details** — each character displays their level, race, and profession with GW2 profession icons
- **Expansion ownership detection** — stories you don't own are dimmed and excluded from stats
- **Thematic story colors** — each story season is tinted with its in-game journal color (jungle green for HoT, purple for PoF, etc.)
- **Persistent caching** with a staleness banner so repeat visits load instantly without forced refreshes
- **Two ways to log in:**
  - **[gw2.me](https://gw2.me)** OAuth2 — no API key needed, authorize with one click
  - **Manual API key** — paste a key from ArenaNet's API settings
- **Responsive design** — fully usable on mobile devices with adaptive layouts for every view
- **Interactive demo** — [try the demo](https://gw2storytracker.com/demo.html) with sample data, no login required
- **GW2-themed UI** with Cinzel display font, gold/amber palette, and a custom compass-rose logo

## Getting Started

### Option A: Login with gw2.me (recommended)

1. Open the [live site](https://gw2storytracker.com).
2. Click **Login with gw2.me** and authorize the app.
3. That's it — no API key management required.

### Option B: Manual API key

1. Go to [account.arena.net/applications](https://account.arena.net/applications) and create an API key with **account**, **characters**, and **progression** permissions.
2. Open the [live site](https://gw2storytracker.com) and enter your API key.
3. Your key is stored in `localStorage` so you only need to enter it once per browser.

## How It Works

The app fetches data from the [Guild Wars 2 API](https://wiki.guildwars2.com/wiki/API:Main):

- `/v2/stories/seasons` and `/v2/stories` for season and story metadata
- `/v2/characters/{name}/quests` for each character's completed quests
- `/v2/characters/{name}/core` for each character's race and profession
- `/v2/account` for expansion ownership and account display name

Quest-to-story mappings come from a pre-built `quest-data.json` file (sourced from `/v2/quests`) so the app doesn't need to make hundreds of API calls at runtime.

When using gw2.me, the app obtains short-lived API subtokens (~10 minutes) via OAuth2 with PKCE. These subtokens are used identically to API keys for GW2 API calls.

## Tech Stack

- React 18 (UMD via CDN)
- Tailwind CSS (CDN)
- Babel Standalone (in-browser JSX)
- No build step — single `index.html` file

## Self-Hosting with Docker

The app can be deployed as a Docker container behind a Traefik reverse proxy:

```bash
docker compose up -d
```

The included `docker-compose.yml` configures Traefik labels for HTTPS with automatic certificate provisioning. The container runs nginx on port 8080. A GitHub Actions workflow automatically triggers a Portainer webhook to redeploy the stack on every push to `main`.

## Updating the Quest Database

The `quest-data.json` file maps quest IDs to story IDs. To refresh it with the latest data from the API:

```powershell
$ids = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/quests"
$all = @()
for ($i = 0; $i -lt $ids.Count; $i += 200) {
    $chunk = $ids[$i..([Math]::Min($i + 199, $ids.Count - 1))]
    $all += Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/quests?ids=$($chunk -join ',')"
    Start-Sleep -Seconds 1
}
$map = [ordered]@{}
$all | Sort-Object id | ForEach-Object { $map["$($_.id)"] = $_.story }
$map | ConvertTo-Json -Compress | Set-Content quest-data.json -Encoding UTF8
```

## License

This project is not affiliated with or endorsed by ArenaNet or NCSOFT. Guild Wars 2 and all associated assets are trademarks of NCSOFT Corporation and ArenaNet, LLC.
