# Logger — implementation plan
Spec: UtilitiesKit/docs/specs/logging/logger.md
Repo: UtilitiesKit
Status: In progress
Run base: 9edf8285708392f143bb5c50877e56d04bba25d6
Baseline: empty
Depends on: —

## Slices
### S1 — Package: skeleton, `LogLevel`, build commands
- ACs: AC-1, AC-2, AC-5
- Area: `Package.swift`, `Sources/UtilitiesKit/LogLevel.swift`, `Tests/UtilitiesKitTests/LogLevelTests.swift`
- Depends on: —
- Skills: —
- Review: full
- Builds: `Package.swift` (tools 6.2, name UtilitiesKit, iOS 26 and macOS 26, Swift 6, library product UtilitiesKit over target UtilitiesKit at `Sources/UtilitiesKit` and test target UtilitiesKitTests at `Tests/UtilitiesKitTests`, no dependencies, resources or `defaultLocalization`); `LogLevel` (`Sources/UtilitiesKit/LogLevel.swift`: public `Sendable`, `CaseIterable` enum, cases `debug`, `info`, `warning`, `error` least to most severe, no raw values or other members); `LogLevelTests.swift` (`Tests/UtilitiesKitTests/LogLevelTests.swift`: `allCases` equals `[debug, info, warning, error]`, test named `AC-5`)
- Done when: AC-1 `Package.swift` reviewed against BR-1 and the product and targets resolve; AC-2 command `xcodebuild -scheme UtilitiesKit -destination 'generic/platform=iOS' build` and command `xcrun swift test --build-system swiftbuild` pass with no warnings and the tests run in UtilitiesKitTests; AC-5 test `AC-5` passes; lint clean; the package builds for iOS and macOS
- Manual ACs: —

### S2 — Contract: `Logger`, spy, lint gate
- ACs: AC-3, AC-4, AC-6, AC-7, AC-8, AC-9, AC-10
- Area: `Sources/UtilitiesKit/Logger.swift`, `Tests/UtilitiesKitTests/LoggerSpy.swift`, `Tests/UtilitiesKitTests/LoggerTests.swift`
- Depends on: S1
- Skills: —
- Review: full
- Builds: `Logger` (`Sources/UtilitiesKit/Logger.swift`: public `Sendable` protocol, single requirement `log(_ message: String, level: LogLevel, category: String)` returning `Void`, not throwing, taking S1's `LogLevel`); `LoggerSpy` (`Tests/UtilitiesKitTests/LoggerSpy.swift`: implements `Logger`, records each call's message, level and category in call order, test target only); `LoggerTests.swift` (`Tests/UtilitiesKitTests/LoggerTests.swift`: one message per level with a different category, four recorded calls in order with message, level and category, test named `AC-6`)
- Done when: AC-3, AC-4, AC-7, AC-8, AC-9 code review of the target's sources; AC-6 test `AC-6` passes; AC-10 `swiftlint lint --strict --quiet` clean with one type per file, each file named after its type and no comments; the iOS build and the package tests pass with no warnings
- Manual ACs: —

### S3 — Owners: README status line, specs README row
- ACs: AC-11
- Area: `README.md`, `docs/specs/README.md`
- Depends on: S2
- Skills: —
- Review: diff-only
- Builds: —
- Done when: AC-11 reviewed: `README.md`'s status line names the package skeleton and the logger contract and no longer calls the package empty; `docs/specs/README.md`'s logging/logger row carries the spec's status; lint clean
- Manual ACs: —

## AC coverage
| AC | Slice | Verified by |
|---|---|---|
| AC-1 | S1 | review of `Package.swift` against BR-1: name UtilitiesKit, tools 6.2, iOS 26 and macOS 26, one library product over target UtilitiesKit and test target UtilitiesKitTests, no dependency, resource or localization entry |
| AC-2 | S1 | command `xcodebuild -scheme UtilitiesKit -destination 'generic/platform=iOS' build`, command `xcrun swift test --build-system swiftbuild`: no warnings, UtilitiesKitTests executed |
| AC-3 | S2 | review of `Sources/UtilitiesKit`: Foundation-only imports, no `#if os`/`#if canImport`, no domain type; SwiftLint `utilitieskit_imports` and `utilitieskit_platform_conditionals`; no String Catalog, resource or user-facing copy in the package |
| AC-4 | S2 | review of `Logger.swift` and `LogLevel.swift`: public `Sendable` protocol with the single `log(_:level:category:)` requirement, not throwing; public `Sendable`, `CaseIterable` enum with the four cases |
| AC-5 | S1 | test `AC-5` in `LogLevelTests.swift` |
| AC-6 | S2 | test `AC-6` in `LoggerTests.swift` with `LoggerSpy`: four calls in order, each with its message, level and category |
| AC-7 | S2 | review of `Sources/UtilitiesKit`: no logger call and no log message literal, no String Catalog, resource or localized copy, no `Locale` or user-facing text in a requirement |
| AC-8 | S2 | review of `Logger.swift`: `category` is a plain `String` parameter supplied at each call, nothing derives it from a type, target or bundle |
| AC-9 | S2 | review of `Logger.swift`: no requirement throws, no call validates its arguments, no API surfaces a logging failure |
| AC-10 | S2 | command `swiftlint lint --strict --quiet`; `git ls-files Sources` file list (one type per file, file named after its type, no comments) |
| AC-11 | S3 | review of `README.md` status line and `docs/specs/README.md` logging/logger row |

## Manual verification
- None: every AC is a package test, a build command or a static review of the package and its docs.

## Out of scope
- App's unified-logging implementation, its subsystem, level and category mapping, and the privacy of the logged text: shell/launch
- Logging a failed recovery action and the category it uses: data/recovery
- The TestUtilitiesKit product, its test target and the Difference dependency: testing/test-utilities
- Other UtilitiesKit contracts: wall clock, formatters, parsers, validators, image scaler
- A String Catalog, resources and localized copy; release tag and `CHANGELOG.md`

## Progress
| Slice | Status | Base | Head | Review |
|---|---|---|---|---|
| S1 | Done | ba55090 | c53f6cc | 0 fixed / 0 rejected |
| S2 | Done | c9422ef | e77f54a | 0 fixed / 0 rejected |
| S3 | Pending | — | — | — |

## Open questions
- None
