# Guild Wars 2 Story Tracker

A single-page web app that tracks your story journal progress across all characters on your Guild Wars 2 account and recommends which character to play next.

**Live site:** [gw2storytracker.com](https://gw2storytracker.com)

## Features

- **Quest-level progress tracking** across all story seasons — from the core Personal Story through the latest expansions, with race-aware filtering for Personal Story arcs
- **"Continue Your Journey" recommendations** — dual cards showing the character/story closest to completion and the next story in chronological order
- **Story Completion Overview** — color-coded pills for every season with completion status; click any pill to jump to that season
- **By Story / By Character views** with cross-view navigation — click a character name or story to jump between views with smooth scrolling and highlight animation
- **Time estimates** powered by [GW2 Story Times](https://gw2storytimes.com) — see estimated remaining playtime per season and per character, with a toggle to show/hide in settings
- **At-a-glance story cards** — collapsed cards show completion status, character count, and the furthest-along character with a progress bar; responsive two-column layout on desktop
- **Act / Chapter / Episode structure** — cards display internal structure (e.g., "4 Acts · 16 Quests") with optional progress bar dividers showing act/chapter boundaries
- **Character management** — sort by progress, name, level, or profession; hide characters to focus on the ones that matter
- **Expansion ownership detection** — stories you don't own are locked and excluded from stats, with manual overrides for content the API can't detect
- **Shareable progress links** — copy a URL encoding your account-wide completion; recipients see a read-only page with your name and per-season status
- **Two ways to log in:** [gw2.me](https://gw2.me) OAuth2 (one-click, multi-account support) or a manual API key
- **Persistent caching** — repeat visits load instantly with a staleness banner and relative timestamps
- **Responsive design** — adaptive layouts for mobile and desktop, installable as a PWA
- **GW2-themed UI** with thematic story colors, Cinzel display font, gold/amber palette, and a custom compass-rose logo
- **Interactive demo** — [try it](https://gw2storytracker.com/demo.html) with sample data, no login required

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

Quest-to-story mappings come from a pre-built `quest-data.json` file (sourced from `/v2/quests`) so the app doesn't need to make hundreds of API calls at runtime. Characters are processed in batches of 5 to stay within API rate limits.

Time estimates are fetched from the [GW2 Story Times](https://gw2storytimes.com) API, a community-driven source of average mission completion times.

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

The included `docker-compose.yml` configures Traefik labels for HTTPS with automatic certificate provisioning. The container runs nginx on port 8080.

### CI/CD

A GitHub Actions workflow (`.github/workflows/deploy.yml`) automatically triggers a Portainer webhook to redeploy the stack on every push to `main`.

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
