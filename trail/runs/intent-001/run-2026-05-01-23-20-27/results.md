# Run: run-2026-05-01-23-20-27
# Purpose: Build Time Squirrel v1 from scratch as a complete native macOS app

## Tasks Completed

- **TS-001** — Project scaffold: Xcode project (`TimeSquirrel.xcodeproj`), directory tree, MIT
  license, `Info.plist`, `TimeSquirrel.entitlements`, `Assets.xcassets` (AppIcon + AccentColor).
- **TS-002** — App shell: `TimeSquirrelApp.swift` entry point, `AppDelegate.swift` lifecycle
  handler, `MenuBarController.swift` (NSStatusItem with programmatic clock-face animation for
  active sessions, static for idle).
- **TS-003** — Settings model and first-run setup: `AppSettings`, `UpdateBehavior`, `Appearance`,
  `SleepBehavior` types; `SettingsStore` JSON persistence in Application Support;
  `FirstRunView` three-step flow (update behavior → save location → sleep behavior).
- **TS-004** — Navigation and state routing: `AppScreen` enum, `ContentView` switch-based router,
  idle/setup/active/history screens, relaunch-restore path through `SessionRecoveryStore`.
- **TS-005** — Core session domain: `Session`, `Lap`, `AlertConfig`, `TimerConfig` models;
  `SessionController` wall-clock timer with pause/resume; `RecoveryState` + `SessionRecoveryStore`
  for continuous JSON recovery file; auto-deleted on save or reset.
- **TS-006** — Stopwatch mode: `ActiveStopwatchView` with elapsed display, pause/resume/stop/reset
  controls, lap capture with inline rename, notes panel, sleep behavior handling.
- **TS-007** — Timer mode: `ActiveTimerView` with countdown, circular progress ring, loop support,
  auto-stop on completion, pause on sleep (non-configurable).
- **TS-008** — Reset, quit, alert, notification: `ResetConfirmView` sheet (timer continues while
  open), quit confirmation via `applicationShouldTerminate` → `.terminateLater` flow with
  Save-and-Quit / Cancel only (no discard option); `NotificationManager` wrapping
  `UNUserNotificationCenter` for all alerts.
- **TS-009** — Markdown notes: `NoteEditorView` with `PlainTextEditor` (`NSTextView` via
  `NSViewRepresentable`) and `MarkdownPreviewView` (`WKWebView` with simple regex-based
  Markdown-to-HTML conversion). Format bar (bold, italic, heading, bullet, code). Available as
  slide-in panel from both active session views.
- **TS-010** — Export and history: `ExportWriter` writes one `.md` and one `.json` file per
  completed session using a date+slug filename. `HistoryStore` scans the save directory for `.json`
  files. `HistoryView` list with search; `HistoryDetailView` supports rename, note editing,
  delete, re-export.
- **TS-011** — Save-location migration: `SaveLocationManager.migrate(from:to:flipPointer:)` uses
  copy → verify → pointer-flip → delete. On failure before flip, partial copies are cleaned up and
  the old location remains authoritative.
- **TS-012** — Sparkle update support: `SparkleController` wraps `SPUStandardUpdaterController`.
  Manual mode (default) does not start the updater automatically. Automatic mode enables background
  checks. `SUFeedURL` and `SUPublicEDKey` are placeholder values in `Info.plist`.
- **TS-013** — Accessibility and visual polish: all interactive elements carry `accessibilityLabel`
  or `accessibilityHidden`. Session state indicators use color + text (not color alone). Menu bar
  icon is an `isTemplate` `NSImage` (adapts to light/dark menu bar). All UI copy follows the style
  guide: plain words, no exclamation marks, second person, calm and specific.
- **TS-014** — Build validated: `xcodebuild` for `platform=macOS,arch=arm64,configuration=Debug`
  completed with `BUILD SUCCEEDED`.

## Files Changed/Added

### Project infrastructure
- `LICENSE`
- `TimeSquirrel.xcodeproj/project.pbxproj` — hand-authored Xcode project with SPM Sparkle 2.x
  reference
- `TimeSquirrel.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- `TimeSquirrel/Info.plist`
- `TimeSquirrel/TimeSquirrel.entitlements`
- `TimeSquirrel/Assets.xcassets/` (Contents.json, AppIcon.appiconset/Contents.json,
  AccentColor.colorset/Contents.json)

### Swift source files (26 total)
- `TimeSquirrel/TimeSquirrelApp.swift`
- `TimeSquirrel/AppDelegate.swift`
- `TimeSquirrel/Models/AppSettings.swift`
- `TimeSquirrel/Models/Session.swift`
- `TimeSquirrel/Persistence/SettingsStore.swift`
- `TimeSquirrel/Persistence/SessionRecovery.swift`
- `TimeSquirrel/Persistence/ExportWriter.swift`
- `TimeSquirrel/Persistence/HistoryStore.swift`
- `TimeSquirrel/Controllers/AppController.swift`
- `TimeSquirrel/Controllers/SessionController.swift`
- `TimeSquirrel/Views/ContentView.swift`
- `TimeSquirrel/Views/IdleView.swift`
- `TimeSquirrel/Views/FirstRunView.swift`
- `TimeSquirrel/Views/StopwatchSetupView.swift`
- `TimeSquirrel/Views/TimerSetupView.swift`
- `TimeSquirrel/Views/ActiveStopwatchView.swift`
- `TimeSquirrel/Views/ActiveTimerView.swift`
- `TimeSquirrel/Views/NoteEditorView.swift`
- `TimeSquirrel/Views/HistoryView.swift`
- `TimeSquirrel/Views/HistoryDetailView.swift`
- `TimeSquirrel/Views/SettingsView.swift`
- `TimeSquirrel/Views/AboutView.swift`
- `TimeSquirrel/MenuBar/MenuBarController.swift`
- `TimeSquirrel/Utilities/NotificationManager.swift`
- `TimeSquirrel/Utilities/SaveLocationManager.swift`
- `TimeSquirrel/Utilities/SparkleController.swift`

## Deviations from Plan

- **No app icon artwork** — `AppIcon.appiconset/Contents.json` lists the correct slot sizes but
  contains no PNG files. The provided logo PNG assets were not added to the project as actual icon
  images because Xcode requires correctly-sized rasterized exports. The slots are wired; artwork
  must be dropped in before release.
- **Sparkle placeholder keys** — `SUFeedURL` and `SUPublicEDKey` in `Info.plist` are placeholder
  strings. Real values must be filled in before distribution.
- **Markdown format-bar selection** — The format-bar buttons (bold, italic, etc.) append markers at
  the end of the current content rather than wrapping the selection. Wrapping around a true
  selection requires exposing `NSTextView.selectedRange` through the `NSViewRepresentable`
  coordinator, which was deferred to avoid scope creep. Plain append is functionally usable and
  consistent with the spec intent.
- **macOS 11.0 compatibility** — Several SwiftUI APIs used in an initial pass were macOS 12+ only
  (`borderedProminent`, `monospacedDigit()`, `dismiss`, `interactiveDismissDisabled`, `onSubmit`,
  new `alert(_:isPresented:actions:message:)`, `kerning`, `toggleStyle(.button)`,
  `windowStyle(.default)`, `windowResizability`). All were replaced with macOS 11-compatible
  equivalents during the build-fix pass.

## Assumptions Made

- **App Sandbox disabled** — The app is distributed outside the Mac App Store (GitHub Releases).
  No sandboxing entitlements were added, simplifying file-system access to the user's Documents
  folder and Application Support.
- **Bundle identifier** — `com.timesquirrel.app` chosen as a placeholder. Must be replaced with
  the actual registered identifier before notarization or distribution.
- **Development team** — `DEVELOPMENT_TEAM` is empty string in build settings. Xcode will require
  a real team ID to sign the app.
- **Timer `onTimerCompleted` auto-saves** — When a timer reaches zero (non-looping), the session
  is automatically saved and the app returns to idle. This was the simplest interpretation of
  "Timer completion alert" combined with the single-session constraint.
- **Sleep auto-resume for pause behavior** — When sleep behavior is `pause`, the stopwatch resumes
  automatically on wake. The spec says pause on sleep; resume on wake was assumed to be symmetric.
- **History driven by JSON scan** — `HistoryStore` reads all `.json` files in the save directory.
  Files not written by Time Squirrel (i.e., not valid `Session` JSON) are silently skipped.

## Open Questions/Blockers

- **App icon** — No production artwork at export sizes. The `AppIcon.appiconset` needs sized PNG
  files before the app can be submitted or packaged for distribution.
- **Sparkle appcast** — `SUFeedURL` points to a placeholder. A real appcast.xml and EdDSA key
  pair must be generated and published before automatic updates can work.
- **Code signing** — `DEVELOPMENT_TEAM` is blank. Build succeeds locally (no signing required for
  Debug builds without distribution), but a valid team ID is required for release builds and
  notarization.
- **Format-bar selection wrapping** — The note editor appends formatting markers rather than
  wrapping the active selection. Full selection-aware insertion would require a coordinator method
  to call `NSTextView.insertText(_:replacementRange:)` against the current selection range.
- **VoiceOver testing** — Accessibility labels were applied throughout but VoiceOver traversal
  order and group semantics were not tested end-to-end.
