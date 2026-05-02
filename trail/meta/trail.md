# trail.md
<!-- This file lives at trail/meta/trail.md. It is the persistent identity of
     the product or project — what it is, who it's for, why it exists, and how
     it's shaped. Every intent inherits this context automatically.

     The Manager reads this file before producing run artifacts for every run.
     The Developer does NOT read this file directly — the Manager surfaces
     relevant product context into the run artifacts.

     Changes rarely. Only update when product identity, audience, or permanent
     constraints shift. -->

Owner: James Sargent, Ventura Nomadica
Last Updated: 2026-05-01

---

## Product Identity

Time Squirrel is a native macOS application for capturing time. The user starts
a session — either an open-ended stopwatch or a fixed countdown timer — and the
app records it. When the session ends, it is saved to local history as a
Markdown file and a JSON file. Both files are owned by the user and live in a
folder they control.

It exists because the macOS built-in Clock app's stopwatch and timer are too
limited for real use, and every capable alternative requires a subscription,
a cloud account, or both. Time Squirrel is the capable alternative that does
not. No accounts. No cloud. No billing. Just a helpful little squirrel
collecting your time and saving it as Markdown or JSON.

Tagline: **Collect your time. Keep it local.**

---

## Users / Audience

**Primary:** A single user — initially the author — who wants to capture how
their time is spent without joining a service, paying a subscription, or handing
data to a third party.

**Secondary:** Anyone who finds the same value in the same simplicity. The
product is open source; secondary users are also potential contributors.

**Anti-users:** Teams. Anyone who needs billing workflows, project hierarchies,
concurrent timers, cloud sync, or external service integrations. Those needs are
well served by Toggl, Harvest, Clockify, and others. Time Squirrel sits beside
those products, not against them.

---

## Permanent Constraints

1. **Local-first. No network, no accounts, no billing.** All data stays on the
   user's device. No cloud sync. No accounts. No subscriptions. No billing. No
   team features. No invoicing. No external project management integrations. The
   app makes no network requests except to check for software updates, and only
   when the user has explicitly opted in. Manual update mode makes zero network
   requests.

2. **macOS only, SwiftUI + AppKit, open source.** Written in SwiftUI with
   AppKit where required. Distributed under the MIT license on GitHub.
   Targets Apple Silicon (M-series) only — Intel Mac support is not a goal
   and the app will not be built or tested for x86_64. Other platforms
   (Windows, Linux, iOS) are explicitly the community's job. No third-party
   dependencies — only what Apple ships. This keeps contributor onboarding
   trivial (clone, open in Xcode, build) and eliminates external maintenance
   burden.

3. **All persistent state lives in plain text files (Markdown and JSON).** This
   applies to session data and to application settings. No `UserDefaults`. No
   SQLite. No binary plists. Session exports are Markdown + JSON pairs. Settings
   are stored as JSON — consistent with the convention established by tools like
   Zed and VS Code. Every piece of state the app owns is human-readable and
   portable without the app.

4. **Single-session model.** At most one session runs at a time, in either
   stopwatch or timer mode. A session has exactly one mode, fixed for its
   lifetime. No concurrent timers, no project hierarchies, no "1 timer +
   1 stopwatch" exception.

5. **Session state is durable.** The app does not lose work due to quit, crash,
   or system events. State is persisted continuously while a session is active.

6. **User controls behavior across system state changes** (sleep, lid close, app
   quit) where multiple sensible behaviors exist. Where only one sensible
   behavior exists, it is not configurable. Timer mode always pauses on sleep —
   no other behavior makes sense for a countdown.

7. **Data is never silently abandoned.** When the user changes the save
   location, all existing session data moves with it via a copy-verify-delete
   pattern: data is copied to the new location and verified before the app's
   pointer is updated; originals are deleted only after the new location is
   confirmed working. If any step fails before the pointer is flipped, the
   operation rolls back fully.

8. **The most private setting is always the default.** Whenever the user faces
   a choice that touches privacy or network behavior, the least-active option is
   pre-selected.

9. **First run is a real surface.** Privacy-adjacent and behavioral defaults are
   presented consciously on first launch. The user makes informed choices
   up front, not buried in settings menus.

10. **Accessibility is not optional.** The app respects macOS system
    accessibility settings: VoiceOver, Dynamic Type, reduced motion, increased
    contrast. This is a baseline requirement, not a deferred feature.

11. **No telemetry, no analytics, no crash reporting.** The app collects nothing
    about the user.

12. **GitHub-only distribution.** Ships from GitHub Releases via Sparkle for
    software updates. The Mac App Store is explicitly out of scope — its
    sandboxing model conflicts with the requirement to write Markdown files to
    any user-chosen location.

13. **The app does not initiate cloud sync.** Time Squirrel writes files to a
    path on the user's machine. Whether that path is synced to iCloud, Dropbox,
    or any other service is determined by the user's OS-level settings, not by
    Time Squirrel.

14. **Built for one user first.** Extensions for other use cases — multiple
    sessions, sync, sharing, integrations — are the community's job, not the
    product's.

---

## Technology & Architecture

- **Platform:** macOS (native), Apple Silicon (M-series ARM) only. Intel Mac
  support is not a goal. The minimum macOS version is the oldest release that
  runs natively on Apple Silicon — currently macOS 11 Big Sur — but intents
  may raise that floor as needed.
- **UI framework:** SwiftUI, with AppKit where SwiftUI cannot reach (menu bar
  icon animation via AppKit frame cycling).
- **Dependencies:** None. Apple frameworks only.
- **Persistence:** Flat files only. Session data: one Markdown + JSON pair per
  session, written to a user-controlled folder (default:
  `~/Documents/TimeSquirrel/`). Settings: a single JSON file in the app's
  support directory. No database, no `UserDefaults`, no binary formats.
- **File naming:** `YYYY-MM-DD-HHMMSS-entry-name.md` / `.json`. ISO date prefix
  for natural sort order; time component prevents same-day collisions; entry
  name slugified (lowercase, hyphens, alphanumeric only). Not configurable.
- **Software updates:** Sparkle. Default: manual. User selects at first run.
- **Distribution:** GitHub Releases. MIT license.
- **Menu bar presence:** Static squirrel icon (idle); animated running-wheel
  squirrel (active session). AppKit frame cycling, no external libraries.

---

## Product Principles

1. **One thing at a time.** The product captures one session, in one mode, on
   one machine. Every decision should reinforce that focus, not erode it.

2. **The Markdown file is the product.** The app is a nice UI for producing
   readable text records of how time was spent. If a feature would compromise
   the cleanness of those records, the feature loses.

3. **No silent network activity.** If the app talks to the network, the user
   knows about it and chose it.

4. **Trust the OS, trust the user.** macOS already handles Spotlight, file
   backup, accessibility, and font management. The app does not duplicate what
   the OS does well. The user already knows how to organize files and manage
   their backups. The app does not patronize them.

5. **Resist features that exist in other products.** If Toggl, Harvest, or
   Clockify already do it, that is evidence it does not belong in Time Squirrel.

---

## Non-Goals (Product Level)

- Cloud sync of any kind
- User accounts, login, or identity
- Subscription, billing, or payment infrastructure
- Team features, sharing, or collaboration
- Multiple concurrent sessions
- Project hierarchies, clients, or tags as structured data (entry name is the
  only label)
- Invoicing or time-billing integrations
- Calendar, task manager, or external service integrations
- In-app search (Spotlight, Finder, and any text editor handle this)
- Telemetry, analytics, or crash reporting
- Mac App Store distribution
- Third-party library dependencies
- Windows, Linux, or iOS ports (community's job, not the product's)

---

## Prior Art / Context

The macOS built-in Clock app provides a stopwatch and timer that are too limited
for real work sessions: no naming, no history, no export, no laps with labels,
no notes. The capable alternatives — Timing, Toggl Track, Harvest, Clockify,
and others — are excellent but require subscriptions, cloud accounts, or both.
Time Squirrel is the capable alternative for users who want none of that. It
does not compete with those products on features; it occupies the space they
explicitly left empty: local, simple, owned by the user.
