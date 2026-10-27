# Test utilities — implementation plan
Spec: UtilitiesKit/docs/specs/testing/test-utilities.md
Repo: UtilitiesKit
Status: Ready
Run base: —
Depends on: —

## Slices
### S1 — Package: target, Difference, `TestLanguage`, `LocaleMatch`, lint gate
- ACs: AC-9
- Area: `Package.swift`, `Sources/TestUtilitiesKit/TestLanguage.swift`, `Sources/TestUtilitiesKit/LocaleMatch.swift`, `Tests/TestUtilitiesKitTests/TestLanguageTests.swift`, `.swiftlint.yml`
- Depends on: —
- Skills: —
- Review: full
- Builds: `Package.swift` (second library product TestUtilitiesKit over target `Sources/TestUtilitiesKit` depending on package Difference pinned `exact: "1.1.0"` and test target TestUtilitiesKitTests at `Tests/TestUtilitiesKitTests`; UtilitiesKit target unchanged); `TestLanguage` (public enum per Data: `code`, `locale`, `testDescription`); `LocaleMatch<Value: Equatable>` (public struct with `language`, `value`, `sourceLocation`, static `polish(_:sourceLocation:)` and `english(_:sourceLocation:)`, `Sendable` where `Value: Sendable`); `.swiftlint.yml` (`utilitieskit_imports` limited to `Sources/UtilitiesKit/`, new `testutilitieskit_imports` allowing Foundation, Testing, Difference in `Sources/TestUtilitiesKit/`, platform-conditional and injected-locale rules cover both); `TestLanguageTests.swift` (test named `AC-9`: `allCases`, codes, locales, descriptions, `LocaleMatch<String>` as `@Test(arguments:)`)
- Done when: AC-9 test `AC-9` passes; lint clean; the package builds for iOS and macOS with no warnings
- Manual ACs: —

### S2 — Core: `match` on `Equatable`, difference issues
- ACs: AC-1, AC-2, AC-3, AC-4, AC-13
- Area: `Sources/TestUtilitiesKit/Equatable+LocaleMatch.swift`, `Tests/TestUtilitiesKitTests/MatchTests.swift`
- Depends on: S1
- Skills: —
- Review: full
- Builds: `Equatable.match(_:in:sourceLocation:)` variadic and `[LocaleMatch<Self>]` overloads (`Sources/TestUtilitiesKit/Equatable+LocaleMatch.swift`): language by locale language code (BR-3), difference issue per BR-5 with the `Expected:`/`Received:` fallback, single `return true` with the one `// Workaround:` line; `MatchTests.swift` (tests named `AC-1`, `AC-2`, `AC-3`, `AC-4`, `AC-13` using `withKnownIssue { … } matching:`)
- Done when: tests `AC-1`, `AC-2`, `AC-3`, `AC-4`, `AC-13` pass; lint clean; iOS and macOS builds with no warnings
- Manual ACs: —

### S3 — Core: missing language, duplicates, array overload parity
- ACs: AC-5, AC-6, AC-8
- Area: `Sources/TestUtilitiesKit/Equatable+LocaleMatch.swift`, `Tests/TestUtilitiesKitTests/MatchEdgeCaseTests.swift`
- Depends on: S2
- Skills: —
- Review: full
- Builds: S2's `match` extended with the no-language issue at the call site (BR-6) and per-entry duplicate issues (BR-7), shared by both overloads; `MatchEdgeCaseTests.swift` (tests named `AC-5`, `AC-6`, `AC-8`)
- Done when: tests `AC-5`, `AC-6`, `AC-8` pass; lint clean; iOS and macOS builds with no warnings
- Manual ACs: —

### S4 — Owners: CLAUDE.md files, review ACs, final gate
- ACs: AC-10, AC-11, AC-12
- Area: `CLAUDE.md` (repo root), `UtilitiesKit/CLAUDE.md`, `.swiftlint.yml`
- Depends on: S3
- Skills: —
- Review: diff-only
- Builds: `UtilitiesKit/CLAUDE.md` › Rules and › Commands, root `CLAUDE.md` › Structure and › Allowed imports updated per BR-12
- Done when: AC-10 and AC-12 code review of sources and owners; AC-11 `swiftlint lint --strict --quiet`, `xcrun swift test --package-path . --build-system swiftbuild` and `xcodebuild -scheme TestUtilitiesKit -destination 'generic/platform=iOS' build` pass with no warnings
- Manual ACs: —

## AC coverage
| AC | Slice | Verified by |
|---|---|---|
| AC-1 | S2 | test `AC-1` |
| AC-2 | S2 | test `AC-2` |
| AC-3 | S2 | test `AC-3` |
| AC-4 | S2 | test `AC-4` |
| AC-5 | S3 | test `AC-5` |
| AC-6 | S3 | test `AC-6` |
| AC-8 | S3 | test `AC-8` |
| AC-9 | S1 | test `AC-9` |
| AC-10 | S4 | review |
| AC-11 | S4 | lint, package tests, iOS build |
| AC-12 | S4 | review |
| AC-13 | S2 | test `AC-13` |

## Manual verification
- None

## Out of scope
- Linking to the apps' test targets, test plan languages: HomeBudgetApps shell/test-languages
- Domain fixtures and doubles: HomeBudgetApps TestKit

## Progress
| Slice | Status | Base | Head | Review |
|---|---|---|---|---|
| S1 | Pending | — | — | — |
| S2 | Pending | — | — | — |
| S3 | Pending | — | — | — |
| S4 | Pending | — | — | — |

## Open questions
- None
