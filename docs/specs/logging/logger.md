# Logger
Status: Planned · Level: capability · Repo: UtilitiesKit · Feature: logging · Module or target: `Package.swift`, UtilitiesKit, UtilitiesKitTests · Depends on: —

## Goal
The UtilitiesKit package exists and builds, and holds the logger contract that Cores and kits inject: one call per event, with a severity, an English message written for logs, and a category chosen by the caller. App implements the contract over unified logging; this spec owns the contract, not the implementation.

## Scope
- In:
  - `Package.swift`: the UtilitiesKit library and target, the UtilitiesKitTests test target, iOS 26 and macOS 26, Swift 6
  - `LogLevel`: debug, info, warning, error
  - `Logger`: one call with a message, a level and the caller's category; its rules for the message and the category, and what a call guarantees
  - Swift Testing tests for the public API in UtilitiesKitTests and SwiftLint for the new sources
- Out:
  - App's implementation with unified logging, its subsystem, its mapping of levels and categories, and the privacy of the logged text: shell/launch
  - Logging a failed recovery action and the category it uses: data/recovery
  - The TestUtilitiesKit product, its test target and the Difference dependency: testing/test-utilities
  - Other UtilitiesKit contracts (wall clock, formatters, parsers, validators, image scaler): the first spec that needs each
  - A String Catalog, resources and localized copy in UtilitiesKit: the first spec that needs copy
  - Release tag and `CHANGELOG.md`

## Glossary
| PL | EN | Meaning |
|---|---|---|
| Rejestrator | Logger | The contract through which Cores and kits write events to the app's log |
| Zdarzenie | Event | One call to the logger: a message at a level in a category |
| Poziom | Level | The severity of an event: debug, info, warning or error |
| Kategoria | Category | The caller-chosen name of the logging area (`launch`, `recovery`) |
| Komunikat | Message | English text written for logs, with no user data |

## User stories
- US-1 As a Core or kit developer I want to log an event through an injected contract so that diagnostics reach the system log without an engine or UI dependency.
- US-2 As an App developer I want one contract and one implementation so that every Core logs the same way and levels mean the same everywhere.
- US-3 As a developer of a public kit I want the package skeleton with its test target so that later utilities land in a linted, tested package.

## Data
- `LogLevel` (public enum, `CaseIterable`, `Sendable`): `debug`, `info`, `warning`, `error`, declared from least to most severe (Q-1).
- `Logger` (public protocol, `Sendable`): `func log(_ message: String, level: LogLevel, category: String)` — synchronous, returns `Void`, never throws (Q-1, Q-2, Q-3).
- Use: `logger.log("Bootstrap failed: \(error)", level: .error, category: "launch")`.
- Package (`Package.swift`): tools version 6.2; name UtilitiesKit; platforms iOS 26 and macOS 26; Swift 6 language mode; one library product UtilitiesKit over the target UtilitiesKit (`Sources/UtilitiesKit`) and the test target UtilitiesKitTests (`Tests/UtilitiesKitTests`); no package dependencies, resources or localization in this increment (TestUtilitiesKit and Difference arrive with testing/test-utilities).

## Rules
- BR-1 `Package.swift` declares the package skeleton in Data: `swift-tools-version: 6.2`, platforms `.iOS(.v26)` and `.macOS(.v26)`, the Swift 6 language mode that the tools version gives by default, one library product over one target, its test target, and no dependencies, resources or `defaultLocalization`.
- BR-2 UtilitiesKit imports Foundation only and is platform-independent: no SwiftUI, AppKit or UIKit, no `#if os` or `#if canImport`, no domain types, and no user-facing copy, String Catalog or resources (`UtilitiesKit/CLAUDE.md` › Rules, `CLAUDE.md` › Allowed imports).
- BR-3 `Logger` is a public `Sendable` protocol with the single requirement `log(_ message: String, level: LogLevel, category: String) -> Void`: synchronous and non-throwing, so an implementation may be called from any isolation domain and concurrently.
- BR-4 `LogLevel` names severity: `debug` development detail, `info` a normal milestone, `warning` an unexpected condition the caller handled, `error` a failed operation. `allCases` is `[debug, info, warning, error]` (Q-1).
- BR-5 The message is English text written for logs only: not user-facing, never localized and never in a String Catalog, and it holds no user data — no domain values, identifiers, names, amounts, dates, titles or messages given by other modules, and no file paths. A caller passes a fixed English message or the log description an error already provides (Q-2).
- BR-6 The category names the logging area and is given by the caller at each call: a short lowercase ASCII identifier that stays stable across releases, e.g. `launch`, `recovery`. It is not inferred from the type, target or bundle (Q-3).
- BR-7 A call never changes the caller's outcome: it cannot throw, it validates neither message nor category, and it reports a logging failure to no one. What an implementation does with the call — subsystem, level and category mapping, privacy — is the App's (shell/launch, Q-4).
- BR-8 Every public API has Swift Testing tests in UtilitiesKitTests: the order of `LogLevel.allCases` and a spy that implements `Logger` and records each call's message, level and category. The spy lives in the test target only.
- BR-9 The sources follow the repo rules: one type per file, a file named after its type, and no comments or doc comments (`CLAUDE.md` › Code style); `swiftlint lint --strict --quiet` passes.
- BR-10 The package builds for iOS 26 and macOS 26 with no warnings and its tests pass (`UtilitiesKit/CLAUDE.md` › Commands).
- BR-11 Owners are updated in the same change: `UtilitiesKit/README.md`'s status line no longer calls the package empty and names the package skeleton and the logger contract; `docs/specs/README.md` carries the logging/logger row in sync with the spec's status.

## Acceptance criteria
- AC-1 (code review) Given `Package.swift`, then it declares tools 6.2, the name UtilitiesKit, iOS 26 and macOS 26, Swift 6 language mode, one library product UtilitiesKit over the target UtilitiesKit and the test target UtilitiesKitTests, and no package dependency, resource or localization (BR-1).
- AC-2 The iOS build command and the package tests command succeed with no warnings, and the tests run UtilitiesKitTests (BR-10).
- AC-3 (code review) Given the target's sources, then they import Foundation only, hold no platform conditional, SwiftUI, AppKit, UIKit or domain type, and the package holds no String Catalog, resource or user-facing copy (BR-2).
- AC-4 (code review) Given `Logger` and `LogLevel`, then `Logger` is a public `Sendable` protocol whose single requirement is `log(_ message: String, level: LogLevel, category: String) -> Void` and does not throw, and `LogLevel` is a public `Sendable`, `CaseIterable` enum with the cases `debug`, `info`, `warning`, `error` (BR-3, BR-4).
- AC-5 `LogLevel.allCases` is `[debug, info, warning, error]` (BR-4).
- AC-6 Given UtilitiesKitTests' spy logger, when it logs one message at each level with a different category, then it records four calls in order, each with the given message, level and category (BR-3, BR-8).
- AC-7 (code review) Given the target, then it holds no logger call and no log message literal, no String Catalog, resource or localized copy, and no requirement takes a `Locale` or user-facing text (BR-5).
- AC-8 (code review) Given the category parameter, then it is a plain `String` supplied at each call and nothing derives it from a type, target or bundle (BR-6).
- AC-9 (code review) Given the contract, then no requirement throws, no call validates its arguments and no API surfaces a logging failure (BR-7).
- AC-10 `swiftlint lint --strict --quiet` passes; the sources have one type per file, a file named after its type and no comments (BR-9).
- AC-11 (code review) Given `UtilitiesKit/README.md`, then its status line names the package skeleton and the logger contract; given `docs/specs/README.md`, then the logging/logger row carries the spec's status (BR-11).

## Open questions
- —

## Changelog
- 2026-10-27 Drafted: package skeleton, `Logger` and `LogLevel`, message and category rules (Q-1–Q-4) (create-spec)
- 2026-10-27 README row follows the spec's status (BR-11, AC-11); `UtilitiesKit/CLAUDE.md` › Rules and `CLAUDE.md` › Code style cited correctly, the undocumented public-access clause dropped (BR-2, BR-9, AC-10); use example interpolates the error (Data); Approved (review-spec round 1, revalidation)
