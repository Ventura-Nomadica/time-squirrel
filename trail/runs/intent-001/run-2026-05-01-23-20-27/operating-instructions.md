# Run: run-2026-05-01-23-20-27
# Purpose: Build Time Squirrel v1 from scratch as a complete native macOS app

## Authority

- This file is the complete operating rule set for this run.
- Read only this file, `tasks.md`, and `dev-prompt.md` from the run folder.
- Do not read `trail/intents/intent-001/intent.md`, `trail/meta/trail.md`,
  `trail/meta/global-operating-instructions.md`, or any other Trail policy or
  scope files.

## Role

- Act only as the Developer.
- Execute the run artifacts.
- Do not change scope, planning, or policy artifacts.

## Scope Discipline

- Build only the Time Squirrel v1 product defined by this run bundle.
- Do not add features, services, platforms, or cleanup work that is not
  required to satisfy the tasks.
- If a choice is ambiguous, choose the simplest interpretation consistent with
  the run artifacts and record the decision in `results.md`.
- If blocked, stop and record the blocker in `results.md`.

## Platform And Technology Constraints

- Target macOS 11.0 or later.
- Target Apple Silicon only. Do not add Intel (`x86_64`) support.
- Use Swift and SwiftUI for the app UI.
- Use AppKit only where SwiftUI cannot reach, specifically including menu bar
  icon frame cycling.
- Use Apple frameworks only, except Sparkle for the update mechanism.
- Do not introduce package-manager setup steps beyond what is required to
  bundle Sparkle in the project.

## Persistence And Privacy Constraints

- Persist all app-owned state in plain text files only.
- Do not use `UserDefaults`, SQLite, Core Data, binary plists, or other binary
  persistence formats for product state.
- Store session exports as one Markdown file and one JSON file per completed
  session in the user-selected save folder.
- Store settings as a single JSON file in the app support directory.
- Store active-session recovery state as a separate JSON file in the app
  support directory.
- Do not add telemetry, analytics, crash reporting, accounts, cloud sync, or
  any network activity beyond Sparkle update checks when the user has opted
  into automatic updates.
- Manual update mode must make zero network requests.

## Product Behavior Constraints

- Support exactly one active session at a time.
- Support two modes only: stopwatch and timer.
- Stopwatch mode supports configurable sleep behavior: `pause`, `continue`,
  `stop`.
- Timer mode always pauses on sleep and is not configurable.
- Reset is the discard path. Quit with an active session offers only save and
  cancel.
- Persist active-session state continuously so relaunch restores the session.
- Changing the save location must use copy, verify, pointer flip, then delete,
  with rollback before pointer flip on failure.

## UI And Copy Constraints

- Use the provided Trail assets when tasks call for them.
- Use macOS system font behavior for the app. Do not embed or use the provided
  marketing font files in the native app.
- Follow the supplied style-guide voice rules for UI copy:
  plain words, calm and specific phrasing, second-person language, no SaaS
  jargon, no exclamation marks.
- Respect system accessibility settings including VoiceOver, Dynamic Type,
  reduced motion, and increased contrast.

## Validation Requirements

- Keep the project buildable in Xcode throughout the run.
- Validate that the app builds for Apple Silicon with no unresolved errors.
- Validate the major persistence flows, export flows, settings flows, and
  session-restoration flows.
- Record validation performed, assumptions made, and any remaining blockers in
  `results.md`.

## Allowed External Inputs

- Only use files explicitly listed in `dev-prompt.md` as Trail inputs.
- The provided image assets and style guide are authoritative references for
  asset usage and product voice.
