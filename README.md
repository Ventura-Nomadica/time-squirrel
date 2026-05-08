# Time Squirrel

**Collect your time. Keep it local.**

A native macOS timer for stopwatch sessions, countdown timers, named laps, alerts, and readable history. No accounts. No cloud. No billing. Just a helpful little squirrel collecting your time and saving it as Markdown and JSON.

---

## What it does

- **Stopwatch mode** — open-ended sessions with optional target duration, repeating interval alerts, and named laps
- **Timer mode** — fixed countdowns with completion alerts and optional looping
- **Local history** — every session saves automatically as a Markdown file and a JSON file in a folder you control
- **Menu bar presence** — static squirrel icon when idle; animated running-wheel squirrel while a session is active
- **Note editor** — freeform Markdown note per session, with format bar and live preview
- **First-class accessibility** — VoiceOver, Dynamic Type, reduced motion, and increased contrast respected throughout

---

## What it doesn't do

- No cloud sync
- No accounts, login, or identity
- No subscriptions or billing
- No team features, sharing, or collaboration
- No telemetry, analytics, or crash reporting
- No third-party dependencies
- No Mac App Store — GitHub Releases only

If you need any of those things, this is not your app.

---

## Requirements

- macOS [version TBD]
- Xcode [version TBD] (to build from source)

---

## Installation

Download the latest release from [GitHub Releases](../../releases). Mount the `.dmg`, drag Time Squirrel to your Applications folder.

Software updates are available via Sparkle. The default is manual — the app checks only when you ask it to. You can switch to automatic updates at first launch or in Settings.

---

## Building from source

```bash
git clone https://github.com/[org]/time-squirrel.git
cd time-squirrel
open TimeSquirrel.xcodeproj
```

Build and run. No package manager. No dependencies to fetch. If it compiles in Xcode, it runs.

---

## Data

Sessions are saved to `~/Documents/TimeSquirrel/` by default. You can change this in Settings — existing data moves with it.

File naming: `YYYY-MM-DD-HHMMSS-entry-name.md` and `.json`. One file pair per session.

Your files are yours. Whether that folder syncs to iCloud or Dropbox is your macOS configuration, not this app's.

---

## Contributing

Issues and pull requests welcome. The scope of the app is intentionally narrow — see the [features and design document](trail/time-squirrel-features-and-design.md) before proposing additions. If a feature belongs in Toggl or Harvest, it doesn't belong here.

---

## License

MIT. See [LICENSE](LICENSE).
