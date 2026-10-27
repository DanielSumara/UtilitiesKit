# Test utilities
Status: Implemented · Level: capability · Repo: UtilitiesKit · Feature: testing · Module or target: TestUtilitiesKit, TestUtilitiesKitTests · Depends on: logging/logger

## Goal
TestUtilitiesKit is a test-only product of the UtilitiesKit package that every unit test target links (Q-1). One test covers Polish and English: it runs once per test language, and each expectation picks its expected value for the locale under test (Q-2, Q-3). A failure points at the line of the expected value and shows only the fields that differ (krzysztofzablocki/Difference).

## Scope
- In:
  - Target and product TestUtilitiesKit in the UtilitiesKit package (`Sources/TestUtilitiesKit`); its package dependency Difference; test target TestUtilitiesKitTests (`Tests/TestUtilitiesKitTests`)
  - `TestLanguage`: the test languages, as Swift Testing arguments
  - `LocaleMatch`: an expected value for one language, with its source location
  - `match` on `Equatable`, optionals included: the locale-keyed expectation used inside `#expect`
- Out:
  - Linking TestUtilitiesKit to the apps' test targets, the test plan's Polish and English configurations, and the apps' testing rules: HomeBudgetApps shell/test-languages
  - Domain fixtures and doubles (clocks, loggers, money, days): HomeBudgetApps TestKit

## Glossary
| PL | EN | Meaning |
|---|---|---|
| Język testu | Test language | A language every language-dependent test runs in: Polish or English |
| Wartość oczekiwana dla języka | Locale match | The value a test expects in one test language, with the line it is written on |
| Różnica | Difference | Field-by-field description of how a received value differs from the expected one |

## User stories
- US-1 As a developer I want one test to cover Polish and English so that copy and formatting are checked in both languages without duplicate tests.
- US-2 As a developer I want a failure to point at the expected value of the failing language and show only what differs so that I see the cause without comparing two long values.
- US-3 As a developer I want the same helpers in every unit test target, public and private repos alike, so that language-dependent tests read the same everywhere.

## Data
- `TestLanguage` (public enum, `CaseIterable`, `Sendable`, `CustomTestStringConvertible`): `polish`, `english`
  - `code`: `String`, the language code: `pl`, `en`
  - `locale`: `Locale`, the locale a test injects: `pl_PL`, `en_GB` (Q-6)
  - `testDescription`: its `code`, so test runs read `pl` and `en`
- `LocaleMatch<Value: Equatable>` (public struct, `Sendable` where `Value: Sendable`, so entries can be test arguments)
  - `language`: `TestLanguage`
  - `value`: `Value`
  - `sourceLocation`: `SourceLocation`, where the entry is written
  - `static func polish(_ value: Value, sourceLocation: SourceLocation = #_sourceLocation) -> LocaleMatch<Value>`; `english(_:sourceLocation:)` alike
- `Equatable.match(_ entries: LocaleMatch<Self>..., in locale: Locale, sourceLocation: SourceLocation = #_sourceLocation) -> Bool`; the same with `[LocaleMatch<Self>]`
- An optional subject uses `Equatable.match` with `LocaleMatch<Wrapped?>` entries, so an entry may expect `nil`; there is no separate `Optional.match` (Q-8)
- Use: `@Test(arguments: TestLanguage.allCases) func title(language: TestLanguage)` builds its subject with `language.locale` and checks `#expect(title.match(.polish("Przypomnienia"), .english("Reminders"), in: language.locale))`

## Rules
- BR-1 TestUtilitiesKit imports Foundation, Testing and Difference only, and holds no domain types. Difference is a package dependency pinned to exactly 1.1.0 (Q-7). Only test targets link TestUtilitiesKit; UtilitiesKit's own target never imports it.
- BR-2 The locale is always passed in. TestUtilitiesKit never reads the current locale, the preferred languages or a bundle's localizations, so a test gives the same result in every process language (Q-2).
- BR-3 An entry matches a locale by the locale's language code. Region, script and variant are ignored: `pl`, `pl_PL` and `pl_DE` match `polish`, and `en`, `en_GB` and `en_US` match `english` (Q-3).
- BR-4 `match` returns `true` whatever happens. A pass records nothing. Each failure is recorded once with `Issue.record`, so the `#expect` around it never adds a second issue (Q-4). Issue comments are in English.
- BR-5 When the matched entry's value differs from the received value, one issue is recorded at the entry's source location, with the comment `Found difference for {code}:`, then Difference's lines for expected against received, one per line. When Difference gives no lines, the comment's next two lines are `Expected: {expected}` and `Received: {received}` instead.
- BR-6 When no entry has the locale's language, one issue is recorded at the call site, with the comment `No value for language {language code} (locale {identifier}); entries: {codes in entry order}`. A locale with no language code is reported the same way, with `—` as its code; with no entries, the list is `—`.
- BR-7 Each entry whose language appears in an earlier entry records one issue at its own line, with the comment `Duplicate value for language {code}`, whatever the locale under test. The first entry with a language is the one matched; nothing crashes.
- BR-8 (removed, Q-8)
- BR-9 `TestLanguage.allCases` is `[polish, english]`, Polish first, as the development language.
- BR-10 TestUtilitiesKit and TestUtilitiesKitTests follow the package's language mode and platforms (`CLAUDE.md` › Code style, `UtilitiesKit/CLAUDE.md` › Rules) and build with no warnings.
- BR-11 Comments follow `CLAUDE.md` › Code style; `match` has a single `return true`, with the one `// Workaround: …` line above it. The sources hold no project headers or constants and no locales from earlier projects (Q-5).
- BR-12 Owners are updated in the same change: `UtilitiesKit/CLAUDE.md` › Rules (a second product TestUtilitiesKit with its test target, its imports, its dependency Difference) and › Commands (the iOS build of TestUtilitiesKit); the root `CLAUDE.md` › Structure (the UtilitiesKit repo's products) and › Allowed imports (TestUtilitiesKit: Foundation, Testing, Difference; test targets only); `.swiftlint.yml` (`utilitieskit_imports` limited to `Sources/UtilitiesKit/`, a rule `testutilitieskit_imports` allowing Foundation, Testing and Difference in `Sources/TestUtilitiesKit/`; the platform-conditional and injected-locale rules keep covering both).

## Acceptance criteria
TestUtilitiesKitTests check recorded issues with `withKnownIssue { … } matching:`, counting the matched issues and checking each one's comment and source location.
- AC-1 Given a received value equal to the `polish` entry's value, when `match` runs in `pl_PL`, then no issue is recorded and it returns `true`; the same for `english` in `en_GB` (BR-4).
- AC-2 Given `polish` and `english` entries, when `match` runs in `pl`, `pl_DE`, `en` and `en_US` with the value of the entry for the locale's language, then no issue is recorded; with the other language's value, one difference issue is recorded at the entry for the locale's language (BR-3, BR-5).
- AC-3 Given two structs that differ in one property, when `match` runs in `pl_PL`, then exactly one issue is recorded, at the `polish` entry's line, its comment starts with `Found difference for pl:` and names that property, and it returns `true`; given two values with the same fields of a type whose `==` returns `false`, the comment's next lines are `Expected: …` and `Received: …` (BR-4, BR-5).
- AC-4 Given a failing `match` inside `#expect`, then exactly one issue is recorded in total (BR-4).
- AC-5 Given only `polish` and `english` entries, when `match` runs in `de_DE`, then one issue is recorded at the call site with `No value for language de (locale de_DE); entries: pl, en`, and it returns `true`; in `Locale(identifier: "")` the comment is `No value for language — (locale ); entries: pl, en`; with no entries in `pl_PL`, it is `No value for language pl (locale pl_PL); entries: —` (BR-6).
- AC-6 Given two `polish` entries with different values, when `match` runs in `pl_PL` with the first value, then one issue is recorded at the second entry's line with `Duplicate value for language pl`, there is no difference issue, and nothing crashes; given three `polish` entries, the second and third each record one; given two `english` entries, when `match` runs in `pl_PL`, the second `english` entry records `Duplicate value for language en` (BR-7).
- AC-7 (removed, Q-8)
- AC-8 Given the same entries as an array and as a variadic list, then both overloads give the same outcome for AC-1, AC-3 and AC-5 (Data).
- AC-9 `TestLanguage.allCases` is `[polish, english]`, with codes `pl` and `en`, locales `pl_PL` and `en_GB`, and test descriptions `pl` and `en`; `LocaleMatch<String>` values can be passed as `@Test(arguments:)` (Data, BR-9).
- AC-10 (review) TestUtilitiesKit never uses `Locale.current`, `Locale.autoupdatingCurrent`, `Locale.preferredLanguages`, `Bundle.preferredLocalizations` or `Bundle.main`; only test targets depend on it; Difference is pinned to exactly 1.1.0 (BR-1, BR-2).
- AC-11 The lint command (with `testutilitieskit_imports` allowing only Foundation, Testing and Difference), the package tests command and the iOS build command for TestUtilitiesKit succeed with no warnings (BR-1, BR-10, BR-12).
- AC-12 (review) The sources follow `CLAUDE.md` › Code style with a single `return true` in `match` and the one `// Workaround:` line above it, and hold no project headers, constants or earlier locales; `UtilitiesKit/CLAUDE.md`, the root `CLAUDE.md` and `.swiftlint.yml` change as BR-12 says (BR-11, BR-12).
- AC-13 Given an optional subject with entries `.polish(nil)` and `.english("Reminders")`, when `match` runs with `nil` in `pl_PL`, then no issue is recorded; with `nil` in `en_GB`, one difference issue is recorded at the `english` entry's line (Data, BR-5).

## Open questions
- —

## Changelog
- 2026-10-27 Drafted from the user's LocaleMatch files and Difference; placement, test languages, match key, `true` with one issue, comments (Q-1–Q-5) (create-spec)
- 2026-10-27 English locale `en_GB` (Data, BR-3, AC-1, AC-2, AC-9, Q-6); Difference pinned to 1.1.0 (BR-1, AC-10, Q-7); `Optional.match` dropped, optionals through `Equatable.match` (Scope, Data, BR-8, AC-7, AC-13, Q-8); fallback when Difference gives no lines (BR-5, AC-3); locale without a language code (AC-5); duplicates per entry in every locale (BR-7, AC-6); observable AC-2; `Sendable` `LocaleMatch` (Data, AC-9); BR-10 and BR-11 cite `CLAUDE.md`; Commands owner (BR-12) (review-spec round 1)
- 2026-10-27 Source paths and `.swiftlint.yml` owner, imports checked by lint (Scope, BR-12, AC-10, AC-11, AC-12); single `return true` (BR-11, AC-12); no entries (BR-6, AC-5); Approved (review-spec revalidation)
- 2026-10-27 Implemented: [plan](../../plans/testing/test-utilities.md), 0f83fdc..f93b778
