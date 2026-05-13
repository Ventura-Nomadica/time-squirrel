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
- **First-class accessibility** — VoiceOver labels and reduced-motion behavior applied throughout

---

## What it doesn't do

- No cloud sync
- No accounts, login, or identity
- No subscriptions or billing
- No team features, sharing, or collaboration
- No telemetry, analytics, or crash reporting
- No Mac App Store — GitHub Releases only

If you need any of those things, this is not your app.

---

## Requirements

- macOS 11.0 or later
- Xcode 13 or later (to build from source)

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

Xcode will resolve the Sparkle dependency via Swift Package Manager on first open. Build and run. No other setup required.

> **Note:** `DEVELOPMENT_TEAM` is empty in build settings. Debug builds run unsigned. A valid team ID is required for release builds and notarization.

---

## Data

Sessions are saved to `~/Documents/TimeSquirrel/` by default. You can change this in Settings — existing data moves with it using a copy-verify-delete migration; the old location stays authoritative until the new one is confirmed.

File naming: `YYYY-MM-DD-entry-name.md` and `.json`. One file pair per session.

Your files are yours. Whether that folder syncs to iCloud or Dropbox is your macOS configuration, not this app's.

> **Privacy note:** Session data, including notes, is stored as unencrypted files in the location you choose.

---

## Pre-release status

The current build is functional but not distribution-ready. Known gaps before a public release:

- **App icon** — slots are wired in `AppIcon.appiconset` but no PNG artwork is present. The app ships with no icon until correctly-sized rasterized exports are dropped in.
- **Sparkle appcast** — `SUFeedURL` in `Info.plist` points to a placeholder. Automatic updates will not work until a real `appcast.xml` and matching EdDSA key pair are published at that URL.
- **Code signing** — `DEVELOPMENT_TEAM` is blank. Release builds and notarization require a valid Apple Developer team ID.

---

## Contributing

Issues and pull requests welcome. The scope of the app is intentionally narrow — see the [features and design document](trail/time-squirrel-features-and-design.md) before proposing additions. If a feature belongs in Toggl or Harvest, it doesn't belong here.

---

## License

MIT. See [LICENSE](LICENSE).
