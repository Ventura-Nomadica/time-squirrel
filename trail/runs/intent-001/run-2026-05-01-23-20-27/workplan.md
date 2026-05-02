# Run: run-2026-05-01-23-20-27
# Purpose: Build Time Squirrel v1 from scratch as a complete native macOS app

## Intent Summary

Build Time Squirrel v1 as a native macOS application from an empty repository.
The product supports one active stopwatch or timer session at a time, durable
session recovery, local history and export in Markdown and JSON, menu bar
presence, first-run setup, settings persisted as JSON, Sparkle-based update
behavior selection, and accessibility-compliant native UI.

## Assumptions

- The repository has no implementation baseline outside the Trail files, so the
  Developer will create the project from scratch.
- Sparkle remains the only permitted external dependency and is treated as
  release infrastructure rather than a product feature library.
- The listed Trail assets are sufficient for iconography, mode selection, and
  style guidance.

## Task Overview

- Establish the Xcode project, target configuration, icon wiring, and baseline
  file structure.
- Build the app shell, menu bar integration, and first-run plus settings
  surfaces.
- Implement the shared session engine and persistence model.
- Implement stopwatch and timer feature sets, including alerts and reset
  behavior.
- Implement notes, exports, history editing, and save-location migration.
- Integrate Sparkle behavior gating and final accessibility plus visual polish.
- Validate the full product and document outcomes in `results.md`.

## Risks And Unknowns

- Sparkle integration details may require project configuration work that is
  larger than the rest of the persistence layer.
- Menu bar animation at very small sizes may require multiple icon treatment
  passes for acceptable contrast in both menu bar appearances.
- Native Markdown editing and preview behavior on macOS 11 may require a mixed
  SwiftUI and AppKit implementation for reliable selection-aware formatting.
- Accessibility compliance may surface layout or animation adjustments late in
  the run.

## Validation Strategy

- Build early and repeatedly against the Apple Silicon target.
- Validate each major persistence boundary: settings JSON, active session state,
  completed session exports, and save-location migration rollback behavior.
- Validate both mode flows: stopwatch and timer, including sleep, pause, reset,
  stop, relaunch restore, alerts, and history re-editing.
- Validate first-run behavior, menu bar states, settings changes, and manual
  versus automatic update gating.
- Record all completed validations, assumptions, and unresolved blockers in
  `results.md`.
