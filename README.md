# Guild Wars 2 Story Tracker

A single-page web app that tracks your story journal progress across all characters on your Guild Wars 2 account and recommends which character to play next for each season.

**Live site:** [mattygroch.github.io/gw2-storytracker](https://mattygroch.github.io/gw2-storytracker/)

## Features

- **Quest-level progress tracking** across all 12 story seasons — from the core Personal Story through Visions of Eternity
- **Race-aware progress** for the Personal Story, filtering out story variants that don't apply to each character's race
- **Per-character breakdown** showing exactly how far each character has progressed in every season
- **"Next Up" recommendations** highlighting the character with the most progress in each incomplete season
- **Fast loading** using a local quest database instead of runtime API calls

## Setup

1. Go to [account.arena.net/applications](https://account.arena.net/applications) and create an API key with **account**, **characters**, and **progression** permissions.
2. Open the [live site](https://mattygroch.github.io/gw2-storytracker/) and enter your API key.
3. Your key is stored in `localStorage` so you only need to enter it once per browser.

## How It Works

The app fetches data from the [Guild Wars 2 API](https://wiki.guildwars2.com/wiki/API:Main):

- `/v2/stories/seasons` and `/v2/stories` for season and story metadata
- `/v2/characters/{name}/quests` for each character's completed quests
- `/v2/characters/{name}/core` for each character's race

Quest-to-story mappings come from a pre-built `quest-data.json` file (sourced from `/v2/quests`) so the app doesn't need to make hundreds of API calls at runtime to resolve quest IDs.

Progress is calculated at the individual quest level for most seasons, with a fallback to story-level tracking for the newest content where quest data isn't yet available in the API.

## Tech Stack

- React 18 (UMD via CDN)
- Tailwind CSS (CDN)
- Babel Standalone (in-browser JSX)
- No build step — single `index.html` file

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
