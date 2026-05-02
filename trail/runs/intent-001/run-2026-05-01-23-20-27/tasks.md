# Run: run-2026-05-01-23-20-27
# Purpose: Build Time Squirrel v1 from scratch as a complete native macOS app

## Task TS-001

- Description: Create the native macOS app project scaffold and baseline repo
  structure for Time Squirrel v1.
- Inputs:
  - `trail/meta/files/Time-Squirrel-Logo-Transparent-Square.png`
- Outputs:
  - Buildable Xcode project targeting macOS 11.0+
  - App target configured for Apple Silicon only
  - MIT license file
  - Initial source, resource, and persistence module structure
- Acceptance Criteria:
  - The project opens and builds on Apple Silicon without requiring package
    manager bootstrapping steps beyond Sparkle bundling.
  - Intel support is not configured as a target goal.
  - The app icon source asset is wired into the project.

## Task TS-002

- Description: Implement the application shell, window lifecycle, menu bar
  presence, and menu structure.
- Inputs:
  - `trail/meta/files/Time-Squirrel-Logo-Transparent.png`
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Main window app shell
  - Menu bar item with idle and active states
  - Menus for Time Squirrel, History, and Help
- Acceptance Criteria:
  - The app presents a standard macOS window application.
  - The menu bar icon is static while idle and supports animated frame cycling
    while a session is active.
  - Menus include About, Settings, Quit, History access, keyboard shortcuts
    help, and a GitHub link surface.

## Task TS-003

- Description: Implement the settings model, first-run setup flow, and JSON
  settings persistence.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - First-run flow for update behavior, save location, and default stopwatch
    sleep behavior
  - Settings UI accessible from the menu bar only
  - JSON settings file in the app support directory
- Acceptance Criteria:
  - First launch presents the three required choices and defaults to the most
    private option.
  - Settings persist in a single JSON file, not `UserDefaults`.
  - Appearance, font, font color, font size, save location, update behavior,
    and future-session defaults can be edited after setup.

## Task TS-004

- Description: Implement navigation and shared app-state flow for idle,
  pre-start, active-session, and relaunch-restored states.
- Inputs:
  - `trail/meta/files/stopwatch.png`
  - `trail/meta/files/timer.png`
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Idle screen with app identity and mode selection
  - Pre-start mode screens with inline session options
  - Active session screens without navigation chrome
  - Relaunch restore routing for in-progress sessions
- Acceptance Criteria:
  - Back navigation is available before start and removed after a session
    begins.
  - Relaunch with an in-progress session bypasses idle and restores directly
    into the active session screen.
  - Shared UI styling follows the provided voice and visual guidance.

## Task TS-005

- Description: Implement the core session domain model and continuous active
  session persistence.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Session, lap, timer configuration, alert configuration, settings, and
    preset models
  - Session controller supporting one active session at a time
  - Active-session JSON state file for crash and relaunch recovery
- Acceptance Criteria:
  - The data model matches the required fields and semantics for stopwatch,
    timer, laps, alerts, notes, and settings.
  - Session state is written continuously during active sessions.
  - Recovery state is deleted when a session is saved or reset.

## Task TS-006

- Description: Implement stopwatch mode behavior and UI.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Stopwatch controls and elapsed-time display
  - Optional target-duration and repeating-interval alert configuration
  - Lap capture, naming, and auto-close-on-stop behavior
  - Configurable sleep behavior handling
- Acceptance Criteria:
  - Stopwatch supports Start, Pause/Resume, Stop, and secondary Reset flow.
  - Elapsed time excludes paused periods unless sleep behavior is `continue`.
  - Laps record start, stop, duration, and optional name while the session
    clock continues.
  - Target and repeating alerts fire based on active session time.

## Task TS-007

- Description: Implement timer mode behavior and UI.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Countdown timer controls and display
  - Built-in presets, custom presets, and custom duration entry
  - Loop behavior, completion alert, and repeating interval alert support
- Acceptance Criteria:
  - Timer supports Start, Pause/Resume, Stop, and secondary Reset flow.
  - Built-in presets include 1, 5, 10, 15, 30, and 60 minutes.
  - Custom presets persist in settings JSON.
  - Timer pauses on sleep, and looped timers reset interval alert timing on
    each cycle.

## Task TS-008

- Description: Implement shared reset, quit, alert, and notification behavior.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Reset confirmation UX that does not pause the running session while
    awaiting confirmation
  - Quit confirmation flow for active sessions
  - macOS notification delivery and optional audible alert behavior
- Acceptance Criteria:
  - Reset requires confirm or cancel, and cancel preserves uninterrupted time.
  - Quit with an active session offers Save and Quit or Cancel, with no discard
    option in the quit prompt.
  - Alerts are delivered as system notifications rather than in-app modals.

## Task TS-009

- Description: Implement the Markdown note editor and preview experience for
  both session modes and history edits.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Freeform Markdown note editor
  - Format bar with bold, italic, heading, bullet, and code block insertion
  - Edit and preview toggle using native text handling and rendered Markdown
- Acceptance Criteria:
  - Notes are editable during and after sessions.
  - Format-bar actions insert around the selection when text is selected and
    at the cursor otherwise.
  - Preview uses native SwiftUI or AppKit capabilities and does not require a
    persistent split view.

## Task TS-010

- Description: Implement completed-session persistence, export, history, and
  re-export flows.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Markdown and JSON export writers
  - Session filename slugging and timestamp naming
  - History list and history detail editing flows
- Acceptance Criteria:
  - Each completed session writes one Markdown file and one JSON file to the
    selected save location.
  - Export contents include all required metadata, alert configuration,
    stopwatch or timer configuration, laps or intervals, and notes.
  - History shows name, mode, date, start time, stop time, and total duration.
  - Users can rename entries, edit notes, delete entries, and re-export both
    file formats.

## Task TS-011

- Description: Implement save-location management and data migration behavior.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Save-location picker and default save folder behavior
  - Copy-verify-delete migration flow with rollback before pointer flip
- Acceptance Criteria:
  - The default save location is `~/Documents/TimeSquirrel/`.
  - Changing the save location moves existing session files using copy,
    verify, pointer flip, then delete.
  - On failure before pointer flip, the old location remains authoritative and
    partial copies are cleaned up.

## Task TS-012

- Description: Integrate update behavior selection and Sparkle-based release
  update support.
- Inputs:
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - Manual and automatic update behavior settings
  - Sparkle integration consistent with GitHub Releases distribution
- Acceptance Criteria:
  - Manual update mode is the default and does not trigger background network
    requests.
  - Automatic update checks occur only when the user explicitly opts in.
  - Update behavior is selected on first run and can be changed in Settings.

## Task TS-013

- Description: Apply accessibility, visual, and final packaging requirements.
- Inputs:
  - `trail/meta/files/Time-Squirrel-Logo-Transparent-Square.png`
  - `trail/meta/files/Time-Squirrel-Logo-Transparent.png`
  - `trail/meta/files/time-squirrel-style-guide.html`
- Outputs:
  - App icon asset set sized correctly for macOS
  - Accessible UI semantics and system-setting responsiveness
  - Final visual polish for menu bar icon visibility at 16 to 22 pixels
- Acceptance Criteria:
  - The app respects VoiceOver, reduced motion, increased contrast, and user
    font settings.
  - The menu bar icon remains legible in light and dark menu bar contexts.
  - No product UI copy uses exclamation marks or SaaS-style jargon.

## Task TS-014

- Description: Validate the full application and document execution outcomes.
- Inputs:
  - `trail/runs/intent-001/run-2026-05-01-23-20-27/results.md`
- Outputs:
  - Completed validation pass
  - Populated `results.md`
- Acceptance Criteria:
  - Validation covers build success and the major user flows required by this
    run.
  - `results.md` records completed tasks, files changed or added, assumptions,
    deviations, and any open blockers.
  - Any unmet requirement is explicitly documented rather than omitted.
