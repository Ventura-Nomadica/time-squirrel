# Intent — Time Squirrel v1

Owner: James Sargent, Ventura Nomadica
Last Updated: 2026-05-01

---

## Purpose

Time Squirrel is a native macOS application for capturing time. This intent
covers the complete v1 build — every feature described in the v1 feature set.
The app lets a single user run stopwatch or countdown timer sessions, capture
named laps, add freeform Markdown notes, receive alerts, and export each
session as a Markdown file and a JSON file owned entirely by the user.

It exists because the macOS built-in Clock app is too limited for real work
sessions and every capable alternative requires a subscription, a cloud
account, or both. Time Squirrel fills that space: local, capable, owned by
the user, with no accounts, no cloud, and no billing.

---

## Constraints

1. **Platform:** macOS 11 (Big Sur) minimum. Apple Silicon (M-series ARM)
   only. Intel Mac support is not a goal and the app must not be built or
   tested for x86_64.

2. **Language and frameworks:** Swift. SwiftUI for all UI. AppKit where
   SwiftUI cannot reach (specifically: menu bar icon animation via frame
   cycling). No other frameworks.

3. **No third-party dependencies.** Apple frameworks only. The project must
   clone, open in Xcode, and build without any package manager steps.

4. **All persistent state lives in plain text files.** No `UserDefaults`.
   No SQLite. No binary plists. No Core Data.
   - Session data: one Markdown + JSON file pair per session, written to a
     user-controlled folder.
   - Settings: a single JSON file in the app's support directory.

5. **Distribution:** GitHub Releases. MIT license. Sparkle for software
   updates (bundled; this is the one permitted external dependency because
   it is explicitly required for the update mechanism — it does not
   constitute a product feature dependency).

6. **No network activity** except Sparkle update checks, and only when the
   user has explicitly opted into automatic updates. Manual update mode
   makes zero network requests.

7. **Accessibility:** the app must respect macOS system accessibility
   settings — VoiceOver, Dynamic Type, reduced motion, increased contrast.
   This is a baseline requirement, not a deferred feature.

8. **No telemetry, analytics, or crash reporting** of any kind.

9. **Mac App Store distribution is out of scope.** GitHub Releases only.

---

## Dependencies & Files

All input files live in `trail/meta/files/` unless noted otherwise.

### Image assets

| File | Purpose |
|---|---|
| `trail/meta/files/Time-Squirrel-Logo.png` | App logo (with background) |
| `trail/meta/files/Time-Squirrel-Logo-Transparent.png` | App logo (transparent, standard) |
| `trail/meta/files/Time-Squirrel-Logo-Transparent-Square.png` | App logo (transparent, square crop) — use for app icon |
| `trail/meta/files/stopwatch.png` | Mode-select button graphic — Stopwatch |
| `trail/meta/files/timer.png` | Mode-select button graphic — Timer |

### Font files

The following fonts are available in `trail/meta/files/fonts/`. These are
web and marketing assets; they are **not** used in the native macOS app.
The app uses the macOS system font per the user's system font picker
settings. These files are declared for completeness and future marketing
intent use.

| File | Family |
|---|---|
| `Fraunces-VariableFont_SOFT,WONK,opsz,wght.ttf` | Fraunces (upright) |
| `Fraunces-Italic-VariableFont_SOFT,WONK,opsz,wght.ttf` | Fraunces (italic) |
| `Inter-VariableFont_opsz,wght.ttf` | Inter (upright) |
| `Inter-Italic-VariableFont_opsz,wght.ttf` | Inter (italic) |
| `JetBrainsMono-VariableFont_wght.ttf` | JetBrains Mono (upright) |
| `JetBrainsMono-Italic-VariableFont_wght.ttf` | JetBrains Mono (italic) |

### Style reference

| File | Purpose |
|---|---|
| `trail/meta/files/time-squirrel-style-guide.html` | Brand colors, typography tokens, voice and writing rules — reference for all UI copy and visual decisions |

### External dependencies

None. This is a new project. No baseline exists.

---

## Scope (In Scope)

### App presence and shell
1. Standard macOS window application
2. Menu bar icon — static squirrel (idle), animated running-wheel squirrel
   (active session) via AppKit frame cycling
3. Menu bar menus: Time Squirrel (About, Settings, Quit), History, Help
   (keyboard shortcuts, link to GitHub)
4. Settings accessible via menu bar only — not surfaced in the main window
   except inline session options

### Navigation model
5. Idle screen: app name, mark, two buttons (Stopwatch, Timer)
6. Mode screens: back button available until Start is pressed; back button
   disappears once session starts
7. Active session: session UI only, no navigation chrome
8. On relaunch with an in-progress session: app navigates directly to active
   session screen, bypassing idle screen

### Session model
9. One session at a time, in either stopwatch or timer mode
10. Session mode is fixed for the session's lifetime
11. Starting a new session while one is running requires stopping (saves) or
    resetting (discards) the current one
12. Session state persisted continuously — survives quit and crash
13. On relaunch with active session: restore to previous state

### Stopwatch mode
14. Controls: Start, Pause/Resume (context-sensitive label), Stop
15. Reset as secondary destructive action (see Reset behavior)
16. Entry naming at any point during or after session
17. Freeform Markdown note (see Note editor)
18. Tracks total elapsed duration (active time, excluding paused periods)
19. Inline session options (visible before Start, hidden once running):
    sleep behavior, optional target duration, optional repeating interval
    alert
20. Optional target duration: fires a one-time alert when reached
21. Optional repeating interval alert: fires every N minutes of active time
22. Laps: user can create laps during session; each lap captures start time,
    stop time, duration, optional name; session clock continues across laps
23. On Stop: session saved to history; open lap auto-closed before save
24. Sleep behavior (user-selectable, inline option, remembered for future
    sessions):
    - Pause (default) — active time only; sleep excluded
    - Continue — wall-clock time; sleep accumulates
    - Stop — session saves and ends on sleep

### Timer mode
25. Controls: Start, Pause/Resume (context-sensitive label), Stop
26. Reset as secondary destructive action (see Reset behavior)
27. Entry naming at any point
28. Freeform Markdown note (see Note editor)
29. Built-in duration presets: 1, 5, 10, 15, 30, 60 minutes
30. Custom presets: user can create and save their own
31. Custom duration: any duration to one-second precision
32. Inline session options (visible before Start, hidden once running): loop,
    optional completion alert, optional repeating interval alert
33. Optional loop: timer restarts automatically on completion; interval
    alerts reset with each loop
34. Optional one-time alert at completion
35. Optional repeating interval alert during countdown
36. On Stop: session saved to history
37. Timer mode always pauses on sleep — not configurable

### Reset behavior
38. Reset control is visually distinct from primary controls: secondary
    styling, physically separated, smaller visual weight
39. Hitting Reset does not immediately discard — session continues running
    while confirmation state is presented
40. User must confirm: "Reset" / "Cancel"
41. If user cancels: session has continued uninterrupted, no time lost
42. On confirmed Reset: session discarded without saving

### Quit behavior
43. Session state persisted continuously — crash or force quit never loses
    session data
44. On deliberate quit (Cmd+Q or menu) with active session: prompt — "Save
    and Quit" or "Cancel." No "Discard and Quit" from quit dialog — Reset
    is the discard mechanism

### Alert behavior
45. Alert types: none, one-time (stopwatch target or timer completion),
    repeating interval
46. Audible alert option using macOS notification sound
47. Alerts delivered via macOS system notifications — no in-app modals
48. Alert timing tied to active session time, not wall-clock time: alerts
    pause when session pauses; reset when timer loops; fire independently
    of other alert types

### Note editor
49. Single freeform note field, available during and after any session
50. Input: raw Markdown text field
51. Format bar above the text field: insertion buttons for bold, italic,
    heading, bullet, code block; inserts around selection if text selected,
    otherwise inserts at cursor
52. Implemented with native SwiftUI/AppKit text handling — no libraries
53. Preview: toggle button switches between edit view and rendered Markdown
    preview (SwiftUI native `AttributedString`); no persistent split pane
54. No length limit

### History
55. Accessible via History menu
56. Local list of completed sessions
57. Each entry displays: name, mode, date, start time, stop time, total
    duration
58. User can: rename entries, edit or add notes, delete entries, re-export
    entries as Markdown or JSON

### Settings
59. Appearance: light, dark, or system
60. Font: system font picker (any font installed on the Mac)
61. Font color: user-selectable
62. Font size: adjustable; timer display also scales with window
63. Save location: user-selectable folder; default `~/Documents/TimeSquirrel/`
64. Changing save location moves all existing session data via
    copy-verify-delete pattern (copy → verify → flip pointer → delete
    originals; full rollback if any step fails before pointer flip)
65. Update behavior: Manual or Automatic (via Sparkle); default Manual;
    selected at first run
66. Save defaults for future sessions

### First-run experience
67. On first launch: short setup presenting three choices:
    - Update behavior (manual / automatic); default manual
    - Save location; default `~/Documents/TimeSquirrel/`
    - Default sleep behavior for stopwatch (Pause / Continue / Stop);
      default Pause
68. Most private option always pre-selected as default

### Export — Markdown
69. Human-readable. One `.md` file per session.
70. Contains: entry name, mode, date, start time, stop time, total duration,
    stopwatch target duration (if used), timer configured duration (if used),
    lap/interval details (if used), user note (if provided)

### Export — JSON
71. Structured. One `.json` file per session.
72. Contains: app version metadata, schema version (separate from app
    version), entry ID, entry name, entry mode, created timestamp, start
    timestamp, stop timestamp, total elapsed seconds, timer configuration
    (if applicable), stopwatch target duration (if applicable), alert
    configuration, lap/interval data, user note (if provided)

### File storage
73. File naming: `YYYY-MM-DD-HHMMSS-entry-name.md` / `.json`
    - ISO date prefix for natural sort order in Finder
    - Time component prevents same-day collisions
    - Entry name slugified: lowercase, spaces to hyphens, non-alphanumeric
      characters removed
    - Not configurable
74. One Markdown + JSON pair per session
75. Default save location: `~/Documents/TimeSquirrel/`
76. Changing save location moves all existing data — never abandons data at
    old location

### Settings persistence
77. Settings stored as a single JSON file in the app's support directory
78. No `UserDefaults`, no binary formats

### Visual identity
79. App icon: uses `Time-Squirrel-Logo-Transparent-Square.png` as source
    asset; must be correctly sized for macOS app icon requirements
80. Menu bar icon: two states — static squirrel (idle), animated
    running-wheel squirrel (active session); AppKit frame cycling;
    must work at 16–22px in both light and dark menu bar contexts
81. UI copy and visual style must follow the brand voice and color token
    guidelines in `trail/meta/files/time-squirrel-style-guide.html`:
    plain, honest, warm, specific, calm, frank; no SaaS verbs; no
    exclamation marks in product UI

---

## Out of Scope (Non-Goals)

These are explicitly excluded from v1. They are not deferred — they are
out of scope until a new intent covers them.

- macOS widget (deferred to v1.1)
- Cloud sync of any kind
- User accounts, login, or identity
- Subscription, billing, or payment infrastructure
- Team features, sharing, or collaboration
- Multiple concurrent sessions
- Project hierarchies, clients, or tags as structured data
- Invoicing or time-billing integrations
- Calendar, task manager, or external service integrations
- In-app search
- Telemetry, analytics, or crash reporting
- Mac App Store distribution
- Intel Mac (x86_64) support
- Windows, Linux, or iOS ports
- Marketing site, README header graphics, contributor brand guidelines
  (post-launch)
- Third-party library dependencies (Sparkle excepted per Constraints)

---

## Assumptions

1. Sparkle is an acceptable external dependency for the update mechanism.
   It does not violate the no-third-party-dependencies constraint because
   it is infrastructure for distribution, not a product feature.

2. The font files in `trail/meta/files/fonts/` are web/marketing assets and
   are not used in the native app. The native app uses the macOS system font.

3. The `stopwatch.png` and `timer.png` assets in `trail/meta/files/` are the
   mode-select button graphics for the idle screen.

4. The `Time-Squirrel-Logo-Transparent-Square.png` asset is the source for
   the app icon. The Developer is responsible for generating all required
   macOS icon sizes from this asset.

5. No baseline exists. This is a new project starting from scratch.

6. The Xcode project targets macOS 11.0 as the deployment target.

7. The schema version in JSON exports is a separate field from the app
   version, to support forward compatibility if the export schema ever
   changes independently of the app version.

8. "Active session time" for alert timing means the running clock excluding
   paused periods — consistent with how elapsed duration is tracked.

---

## Specifics

### Data model

#### Session
```
id:               UUID (string)
name:             String (user-provided; empty string if unnamed)
mode:             "stopwatch" | "timer"
created_at:       ISO 8601 timestamp
started_at:       ISO 8601 timestamp
stopped_at:       ISO 8601 timestamp (null if session in progress)
elapsed_seconds:  Int (active time only, excluding paused periods)
laps:             [Lap] (empty array if no laps)
note:             String (raw Markdown; empty string if no note)
sleep_behavior:   "pause" | "continue" | "stop"  (stopwatch only)
target_duration:  Int? (seconds; stopwatch optional target)
timer_config:     TimerConfig? (timer mode only)
alert_config:     AlertConfig
```

#### Lap
```
id:               UUID (string)
index:            Int (1-based)
name:             String (user-provided; empty string if unnamed)
started_at:       ISO 8601 timestamp
stopped_at:       ISO 8601 timestamp
elapsed_seconds:  Int
```

#### TimerConfig
```
duration_seconds: Int
loop:             Bool
preset_name:      String? (name of preset if selected; null if custom)
```

#### AlertConfig
```
type:             "none" | "one_time" | "repeating" | "both"
interval_seconds: Int? (repeating interval; null if type is "none" or
                  "one_time")
audible:          Bool
```

#### Settings (JSON file)
```
appearance:            "light" | "dark" | "system"
font_name:             String (system font name)
font_color:            String (hex color, e.g. "#3a2c1f")
font_size:             Int (points)
save_location:         String (absolute path)
update_behavior:       "manual" | "automatic"
default_sleep_behavior: "pause" | "continue" | "stop"
timer_custom_presets:  [TimerPreset]
```

#### TimerPreset
```
id:               UUID (string)
name:             String
duration_seconds: Int
```

### File naming examples

A session named "Deep work block" started on 2026-05-01 at 09:32:47:
```
2026-05-01-093247-deep-work-block.md
2026-05-01-093247-deep-work-block.json
```

A session with no name:
```
2026-05-01-093247-.md
2026-05-01-093247-.json
```

### JSON export schema

```json
{
  "app_version": "1.0.0",
  "schema_version": "1",
  "id": "uuid-string",
  "name": "Deep work block",
  "mode": "stopwatch",
  "created_at": "2026-05-01T09:32:47Z",
  "started_at": "2026-05-01T09:32:47Z",
  "stopped_at": "2026-05-01T11:15:22Z",
  "elapsed_seconds": 6155,
  "sleep_behavior": "pause",
  "target_duration_seconds": null,
  "timer_config": null,
  "alert_config": {
    "type": "repeating",
    "interval_seconds": 1500,
    "audible": true
  },
  "laps": [
    {
      "id": "uuid-string",
      "index": 1,
      "name": "Research",
      "started_at": "2026-05-01T09:32:47Z",
      "stopped_at": "2026-05-01T10:15:00Z",
      "elapsed_seconds": 2533
    }
  ],
  "note": "## Notes\n\nFocused on architecture doc."
}
```

### Markdown export format

```markdown
# Deep work block

**Mode:** Stopwatch
**Date:** 2026-05-01
**Started:** 09:32:47
**Stopped:** 11:15:22
**Duration:** 1h 42m 35s
**Target duration:** —
**Sleep behavior:** Pause

## Laps

| # | Name | Start | Stop | Duration |
|---|------|-------|------|----------|
| 1 | Research | 09:32:47 | 10:15:00 | 42m 13s |
| 2 | Writing | 10:15:00 | 11:15:22 | 1h 0m 22s |

## Notes

Focused on architecture doc.
```

### Session state persistence

Session state is written to a JSON state file continuously during an active
session. This file is separate from the export files. On relaunch, the app
checks for this state file. If found and the session is not stopped, the app
restores to the active session screen. The state file is deleted when a
session is saved or reset.

State file location: app's support directory (same folder as settings JSON).

### Copy-verify-delete pattern for save location changes

1. Copy all session files to the new location.
2. Verify each file was written correctly (size check or hash comparison).
3. Update the app's save location pointer in settings.
4. Delete the originals from the old location.

If any step fails before step 3 completes, roll back fully: delete any
partially copied files, keep the pointer at the old location, and report
the failure to the user. Never leave the app pointing at a location where
data may be incomplete.

### Brand voice rules (summary from style guide)

All UI copy must follow these rules from the style guide:
- Use plain words: "Save," "Stop," "Reset" — not "persist," "halt,"
  "reinitialize"
- No exclamation marks anywhere in product UI
- No SaaS verbs: no "leverage," "empower," "streamline," "supercharge"
- Use second person ("your time," "your machine")
- If a feature isn't there, say so plainly — do not hedge with "coming soon"
- Acknowledgment copy is specific: name the file, the duration, the path

---

## Deliverables

1. A complete, buildable Xcode project for Time Squirrel v1, targeting
   macOS 11.0+, Apple Silicon only, with no unresolved build errors or
   warnings.
2. All features listed in Scope implemented and functional.
3. Session Markdown and JSON export files writing correctly to the
   user-selected save location.
4. Settings persisted as a JSON file in the app's support directory.
5. Session state file persisting continuously and restoring correctly on
   relaunch.
6. App icon correctly sized and set from the provided square logo asset.
7. Menu bar icon with both states (idle static, active animated) functioning
   correctly at 16–22px in light and dark menu bar contexts.
8. First-run experience presenting the three setup choices on first launch
   only.

---

## Acceptance Criteria

### App presence
- [ ] App launches to the idle screen (app name, mark, Stopwatch button,
      Timer button — nothing else)
- [ ] Menu bar shows static squirrel icon when no session is active
- [ ] Menu bar shows animated running-wheel squirrel when a session is active
- [ ] Menu bar menus are present and functional: Time Squirrel, History, Help

### Session model
- [ ] Only one session can be active at a time
- [ ] Attempting to start a new session while one is active prompts the user
      to stop or reset the current session
- [ ] Session mode cannot change after Start is pressed
- [ ] Force-quitting the app and relaunching restores the active session

### Stopwatch mode
- [ ] Start begins elapsed time tracking
- [ ] Pause stops elapsed time; Resume continues from where it stopped
- [ ] Stop saves the session to history and the session files are written
- [ ] Lap button creates a lap; session clock continues; lap records its own
      start, stop, and duration
- [ ] On Stop with an open lap, the lap is auto-closed before save
- [ ] Sleep behavior Pause: elapsed time does not increment while machine is
      asleep
- [ ] Sleep behavior Continue: elapsed time increments across sleep
- [ ] Sleep behavior Stop: session saves when machine sleeps
- [ ] Target duration alert fires once when elapsed active time reaches the
      target; does not affect repeating interval alerts
- [ ] Repeating interval alert fires every N minutes of active time; pauses
      when session pauses

### Timer mode
- [ ] Built-in presets (1, 5, 10, 15, 30, 60 min) populate the duration
      correctly
- [ ] Custom presets can be created, named, saved, and selected
- [ ] Custom duration can be set to any value with one-second precision
- [ ] Timer counts down correctly
- [ ] Timer always pauses when machine sleeps; there is no setting to change
      this
- [ ] Loop: timer restarts automatically on reaching zero when loop is enabled
- [ ] Completion alert fires when timer reaches zero (non-loop) or each loop
      completion (loop enabled)
- [ ] Repeating interval alert fires correctly during countdown; resets on
      each loop

### Reset behavior
- [ ] Reset control is visually distinct from Stop and Pause
- [ ] Pressing Reset does not immediately discard; confirmation is required
- [ ] Cancelling Reset leaves the session running with no lost time
- [ ] Confirming Reset discards the session without saving

### Quit behavior
- [ ] Cmd+Q with active session presents "Save and Quit" / "Cancel" prompt
- [ ] "Save and Quit" saves the session and quits
- [ ] "Cancel" returns to the active session
- [ ] There is no "Discard and Quit" option in the quit dialog

### Note editor
- [ ] Note field is available during and after a session
- [ ] Format bar inserts Markdown syntax at cursor or around selection
- [ ] Preview toggle renders Markdown correctly
- [ ] Note is preserved in both Markdown and JSON exports

### History
- [ ] History lists all completed sessions with name, mode, date, start
      time, stop time, total duration
- [ ] Entries can be renamed
- [ ] Notes can be edited or added to existing entries
- [ ] Entries can be deleted
- [ ] Entries can be re-exported as Markdown or JSON

### Settings
- [ ] Appearance setting changes the app appearance (light/dark/system)
- [ ] Font setting accepts any installed system font
- [ ] Font color setting changes the display font color
- [ ] Font size setting changes the display font size
- [ ] Save location change triggers copy-verify-delete; all existing session
      files are present at the new location after the change
- [ ] Save location change with a simulated failure rolls back fully; app
      continues using the old location; no data is lost
- [ ] Update behavior setting is respected (manual: no network calls;
      automatic: Sparkle checks for updates)

### First-run experience
- [ ] First-run setup appears on first launch only
- [ ] All three choices are presented: update behavior, save location, sleep
      behavior
- [ ] Most private option (manual updates, Pause sleep behavior) is
      pre-selected
- [ ] Choices are saved to settings correctly
- [ ] First-run setup does not appear on subsequent launches

### File export
- [ ] Each completed session produces exactly one `.md` and one `.json` file
- [ ] File names follow `YYYY-MM-DD-HHMMSS-entry-name` format with slugified
      entry name
- [ ] Markdown file contains all required fields
- [ ] JSON file contains all required fields including schema_version and
      app_version as separate fields
- [ ] Files are written to the user-selected save location

### Accessibility
- [ ] VoiceOver can navigate all interactive elements
- [ ] Reduced motion setting suppresses menu bar animation
- [ ] Dynamic Type size changes are respected

---

## Notes

- The macOS widget is explicitly deferred to v1.1. The menu bar icon with
  its two states (idle/active) covers the glanceable session status use case
  for v1.
- Sparkle is treated as infrastructure, not a product dependency, and is the
  one permitted exception to the no-third-party-dependencies constraint.
- The schema_version field in JSON exports is separate from app_version by
  design. If the export schema changes in a future version, the schema_version
  can increment independently without implying an app version change.
- Session state persistence uses a separate state file, not the export files.
  The export files are final outputs written on Stop. The state file is the
  live record written during an active session.
- Whether the save location path is synced to iCloud or any other cloud
  service is determined by the user's macOS settings, not by Time Squirrel.
  The app neither prevents nor encourages cloud sync.
