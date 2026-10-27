# Test utilities
Status: Draft · Level: capability · Repo: UtilitiesKit · Feature: testing · Module or target: TestUtilitiesKit, TestUtilitiesKitTests · Depends on: logging/logger

## Goal
TestUtilitiesKit is a test-only product of the UtilitiesKit package that every unit test target links (Q-1). One test covers Polish and English: it runs once per test language, and each expectation picks its expected value for the locale under test (Q-2, Q-3). A failure points at the line of the expected value and shows only the fields that differ (krzysztofzablocki/Difference).

## Scope
- In:
  - Target and product TestUtilitiesKit in the UtilitiesKit package; its package dependency Difference; test target TestUtilitiesKitTests
  - `TestLanguage`: the test languages, as Swift Testing arguments
  - `LocaleMatch`: an expected value for one language, with its source location
  - `match` on `Equatable` and `Optional`: the locale-keyed expectation used inside `#expect`
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
  - `locale`: `Locale`, the locale a test injects: `pl_PL`, `en_PL` (Q-6)
  - `testDescription`: its `code`, so test runs read `pl` and `en`
- `LocaleMatch<Value: Equatable>` (public struct)
  - `language`: `TestLanguage`
  - `value`: `Value`
  - `sourceLocation`: `SourceLocation`, where the entry is written
  - `static func polish(_ value: Value, sourceLocation: SourceLocation = #_sourceLocation) -> LocaleMatch<Value>`; `english(_:sourceLocation:)` alike
- `Equatable.match(_ entries: LocaleMatch<Self>..., in locale: Locale, sourceLocation: SourceLocation = #_sourceLocation) -> Bool`; the same with `[LocaleMatch<Self>]`
- `Optional.match(_ entries: LocaleMatch<Wrapped>..., in locale: Locale, sourceLocation: SourceLocation = #_sourceLocation) -> Bool`, where `Wrapped: Equatable`
- Use: `@Test(arguments: TestLanguage.allCases) func title(language: TestLanguage)` builds its subject with `language.locale` and checks `#expect(title.match(.polish("Przypomnienia"), .english("Reminders"), in: language.locale))`

## Rules
- BR-1 TestUtilitiesKit imports Foundation, Testing and Difference only, and holds no domain types. Difference is a package dependency pinned to an exact version (Q-7). Only test targets link TestUtilitiesKit; UtilitiesKit's own target never imports it.
- BR-2 The locale is always passed in. TestUtilitiesKit never reads the current locale, the preferred languages or a bundle's localizations, so a test gives the same result in every process language (Q-2).
- BR-3 An entry matches a locale by the locale's language code. Region, script and variant are ignored: `pl`, `pl_PL` and `pl_DE` match `polish`, and `en`, `en_PL` and `en_GB` match `english` (Q-3).
- BR-4 `match` returns `true` whatever happens. A pass records nothing. Each failure is recorded once with `Issue.record`, so the `#expect` around it never adds a second issue (Q-4). Issue comments are in English.
- BR-5 When the matched entry's value differs from the received value, one issue is recorded at the entry's source location, with the comment `Found difference for {code}:`, then Difference's lines for expected against received, one per line.
- BR-6 When no entry has the locale's language, one issue is recorded at the call site, with the comment `No value for language {language code} (locale {identifier}); entries: {codes in entry order}`. A locale with no language code is reported the same way, with `—` as its code.
- BR-7 When two entries share a language, one issue is recorded at the later entry, with the comment `Duplicate value for language {code}`. The first entry with that language is matched; nothing crashes.
- BR-8 `Optional.match` on `nil` records one issue at the call site, with the comment `No value`, and evaluates no entry. On a value it behaves as `Equatable.match` on the wrapped value.
- BR-9 `TestLanguage.allCases` is `[polish, english]`, Polish first, as the development language.
- BR-10 TestUtilitiesKit and TestUtilitiesKitTests build in Swift 6 language mode with strict concurrency for iOS 26 and macOS 26, with no warnings.
- BR-11 The sources hold no project headers, doc comments or project constants, and carry over no locale from earlier projects. The one explanation that stays is a single line `// Workaround: …` above `return true` after an issue is recorded (Q-5).
- BR-12 Owners are updated in the same change: `UtilitiesKit/CLAUDE.md` › Rules (a second product TestUtilitiesKit with its test target, its imports, its dependency Difference); the root `CLAUDE.md` › Structure (the UtilitiesKit repo's products) and › Allowed imports (TestUtilitiesKit: Foundation, Testing, Difference; test targets only).

## Acceptance criteria
TestUtilitiesKitTests check recorded issues with `withKnownIssue { … } matching:`, counting the matched issues and checking each one's comment and source location.
- AC-1 Given a received value equal to the `polish` entry's value, when `match` runs in `pl_PL`, then no issue is recorded and it returns `true`; the same for `english` in `en_PL` (BR-4).
- AC-2 Given `polish` and `english` entries, when `match` runs in `pl`, `pl_DE`, `en` and `en_GB`, then each matches the entry for its language (BR-3).
- AC-3 Given two structs that differ in one property, when `match` runs in `pl_PL`, then exactly one issue is recorded, at the `polish` entry's line, its comment starts with `Found difference for pl:` and names that property, and it returns `true` (BR-4, BR-5).
- AC-4 Given a failing `match` inside `#expect`, then exactly one issue is recorded in total (BR-4).
- AC-5 Given only `polish` and `english` entries, when `match` runs in `de_DE`, then one issue is recorded at the call site with `No value for language de (locale de_DE); entries: pl, en`, and it returns `true` (BR-6).
- AC-6 Given two `polish` entries with different values, when `match` runs in `pl_PL` with the first value, then one issue is recorded at the second entry's line with `Duplicate value for language pl`, there is no difference issue, and nothing crashes (BR-7).
- AC-7 Given `nil`, when `Optional.match` runs, then one issue `No value` is recorded at the call site and it returns `true`; given a wrapped value, the outcome is the same as AC-1 and AC-3 (BR-8).
- AC-8 Given the same entries as an array and as a variadic list, then both overloads give the same outcome for AC-1, AC-3 and AC-5 (Data).
- AC-9 `TestLanguage.allCases` is `[polish, english]`, with codes `pl` and `en`, locales `pl_PL` and `en_PL`, and test descriptions `pl` and `en`; a test with `arguments: TestLanguage.allCases` runs twice (Data, BR-9).
- AC-10 (review) TestUtilitiesKit imports only Foundation, Testing and Difference; it never uses `Locale.current`, `Locale.autoupdatingCurrent`, `Locale.preferredLanguages`, `Bundle.preferredLocalizations` or `Bundle.main`; only test targets depend on it; Difference is pinned to an exact version (BR-1, BR-2).
- AC-11 The package tests command and the iOS build command for TestUtilitiesKit succeed with no warnings (BR-10).
- AC-12 (review) The sources hold no headers, doc comments or project constants, apart from one `// Workaround:` line per `return true` after an issue; `UtilitiesKit/CLAUDE.md` and the root `CLAUDE.md` name TestUtilitiesKit as BR-12 says (BR-11, BR-12).

## Open questions
- Q-6 Which locale does `TestLanguage.english` inject: `en_PL` (an English-language user in Poland, the app locale shell/app-project BR-10 builds for the Polish market) or `en` (what existing tests pass)? Proposed: `en_PL`, so formatted amounts and dates use the Polish region in both languages.
- Q-7 Does the Difference release chosen build under Swift 6 strict concurrency with no warnings (BR-10)? If not: pin a fork or commit that does, or replace Difference with a `Mirror`-based diff in TestUtilitiesKit.

## Changelog
- 2026-10-27 Drafted from the user's LocaleMatch files and Difference; placement, test languages, match key, `true` with one issue, comments (Q-1–Q-5) (create-spec)
