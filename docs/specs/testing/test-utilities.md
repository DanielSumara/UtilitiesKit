# Test utilities
Status: Planned · Level: capability · Repo: UtilitiesKit · Feature: testing · Module or target: TestUtilitiesKit, TestUtilitiesKitTests · Depends on: logging/logger

## Goal
TestUtilitiesKit is a test-only product of the UtilitiesKit package that every unit test target links (Q-1). One test covers Polish and English: a test plan runs it once in a Polish and once in an English configuration, and each expectation picks its expected value by the language of the process locale, with no locale passed by the test (Q-10). A failure points at the line of the expected value and shows only the fields that differ (krzysztofzablocki/Difference).

## Scope
- In:
  - Target and product TestUtilitiesKit in the UtilitiesKit package (`Sources/TestUtilitiesKit`); its package dependency Difference; test target TestUtilitiesKitTests (`Tests/TestUtilitiesKitTests`)
  - `TestLanguage`: the test languages
  - `LanguageMatch`: an expected value for one language, with its source location (Q-12)
  - `match` on `Equatable`, optionals included: the language-keyed expectation used inside `#expect`
  - The UtilitiesKit test plan with its Polish and English configurations, run with `xcodebuild` (Q-11)
- Out:
  - Linking TestUtilitiesKit to the apps' test targets, the apps' test plan configurations, how app tests build subjects with a locale, and the apps' testing rules: HomeBudgetApps shell/test-languages
  - Domain fixtures and doubles (clocks, loggers, money, days): HomeBudgetApps TestKit

## Glossary
| PL | EN | Meaning |
|---|---|---|
| Język testu | Test language | A language every language-dependent test runs in: Polish or English |
| Konfiguracja językowa | Language configuration | A test plan configuration that sets the application language and region of the test process: Polish (`pl`, PL) or English (`en`, GB) |
| Wartość oczekiwana dla języka | Language match | The value a test expects in one test language, with the line it is written on |
| Różnica | Difference | Field-by-field description of how a received value differs from the expected one |

## User stories
- US-1 As a developer I want one test to cover Polish and English so that copy and formatting are checked in both languages without duplicate tests and without passing a locale.
- US-2 As a developer I want a failure to point at the expected value of the failing language and show only what differs so that I see the cause without comparing two long values.
- US-3 As a developer I want the same helpers in every unit test target, public and private repos alike, so that language-dependent tests read the same everywhere.

## Data
- `TestLanguage` (public enum, `CaseIterable`, `Sendable`, `CustomTestStringConvertible`): `polish`, `english`
  - `code`: `String`, the language code: `pl`, `en`
  - `locale`: `Locale`, the locale of its language configuration: `pl_PL`, `en_GB` (Q-6)
  - `testDescription`: its `code`
- `LanguageMatch<Value: Equatable>` (public struct, `Sendable` where `Value: Sendable`, so entries can be test arguments)
  - `language`: `TestLanguage`
  - `value`: `Value`
  - `sourceLocation`: `SourceLocation`, where the entry is written
  - `static func polish(_ value: Value, sourceLocation: SourceLocation = #_sourceLocation) -> LanguageMatch<Value>`; `english(_:sourceLocation:)` alike
- `Equatable.match(_ entries: LanguageMatch<Self>..., in locale: Locale = .current, sourceLocation: SourceLocation = #_sourceLocation) -> Bool`; the same with `[LanguageMatch<Self>]`
- An optional subject uses `Equatable.match` with `LanguageMatch<Wrapped?>` entries, so an entry may expect `nil`; there is no separate `Optional.match` (Q-8)
- Use: `#expect(sut.title.match(.polish("Przypomnienia"), .english("Reminders")))`, with no locale, no test arguments and no trait; the test plan runs it in both language configurations. A test that injects its own locale passes it: `match(…, in: locale)`

## Rules
- BR-1 TestUtilitiesKit imports Foundation, Testing and Difference only, and holds no domain types. Difference is a package dependency pinned to exactly 1.1.0 (Q-7). Only test targets link TestUtilitiesKit; UtilitiesKit's own target never imports it.
- BR-2 The locale under test is `match`'s `locale`, which defaults to the process locale, `Locale.current`, set by the running language configuration. That default is the only place TestUtilitiesKit reads process state: it never reads the preferred languages or a bundle's localizations (Q-10).
- BR-3 An entry matches a locale by the locale's language code. Region, script and variant are ignored: `pl`, `pl_PL` and `pl_DE` match `polish`, and `en`, `en_GB` and `en_US` match `english` (Q-3).
- BR-4 `match` returns `true` whatever happens. A pass records nothing. Each failure is recorded once with `Issue.record`, so the `#expect` around it never adds a second issue (Q-4). Issue comments are in English.
- BR-5 The matched entry is the first entry whose language is the locale's language. When its value differs from the received value, one issue is recorded at the entry's source location, with the comment `Found difference for {code}:`, then Difference's lines for expected against received, one per line. When Difference gives no lines, the comment's next two lines are `Expected: {expected}` and `Received: {received}` instead.
- BR-6 When no entry has the locale's language, one issue is recorded at the call site, with the comment `No value for language {language code} (locale {identifier}); entries: {codes in entry order}`. A locale with no language code is reported the same way, with `—` as its code; with no entries, the list is `—`. So an expectation with only a `polish` entry fails in the English configuration (Q-10).
- BR-7 Each entry whose language appears in an earlier entry records one issue at its own line, with the comment `Duplicate value for language {code}`, whatever the locale under test. The first entry with a language is the one matched; nothing crashes.
- BR-8 (removed, Q-8)
- BR-9 `TestLanguage.allCases` is `[polish, english]`, Polish first, as the development language.
- BR-10 TestUtilitiesKit and TestUtilitiesKitTests follow the package's language mode and platforms (`CLAUDE.md` › Code style, `UtilitiesKit/CLAUDE.md` › Rules) and build with no warnings.
- BR-11 Comments follow `CLAUDE.md` › Code style; `match` has a single `return true`, with the one `// Workaround: …` line above it. The sources hold no project headers or constants and no locales from earlier projects (Q-5).
- BR-12 Owners are updated in the same change: `UtilitiesKit/CLAUDE.md` › Rules (a second product TestUtilitiesKit with its test target, its imports, its dependency Difference; tests run in both language configurations) and › Commands (the tests command of BR-13 replaces `swift test`; the iOS build of TestUtilitiesKit); the root `CLAUDE.md` › Structure (the UtilitiesKit repo's products), › Allowed imports (TestUtilitiesKit: Foundation, Testing, Difference; test targets only) and › Commands (UtilitiesKit's tests through its test plan); `.swiftlint.yml` (`utilitieskit_imports` limited to `Sources/UtilitiesKit/`, a rule `testutilitieskit_imports` allowing Foundation, Testing and Difference in `Sources/TestUtilitiesKit/`; the platform-conditional and injected-locale rules keep covering both); `.gitignore` and the workspace `.claude/settings.json` (BR-13).
- BR-13 The package has a test plan `UtilitiesKit.xctestplan` at its root with the configurations Polish (application language `pl`, region PL) and English (`en`, GB), holding UtilitiesKitTests and TestUtilitiesKitTests, the default plan of the shared scheme `UtilitiesKit-Package`. The scheme is committed and readable by agents: `.gitignore` keeps ignoring `.swiftpm/` except `.swiftpm/xcode/xcshareddata/xcschemes/`, re-including each level on the way down, since git skips everything under an ignored folder; the workspace `.claude/settings.json` replaces its `Read(**/.swiftpm/**)` deny with denies that leave `.swiftpm/xcode/xcshareddata/xcschemes/` readable (Q-13). Tests run with `xcodebuild -scheme UtilitiesKit-Package -testPlan UtilitiesKit -destination 'platform=macOS' test`, every test once per configuration (Q-11).

## Acceptance criteria
TestUtilitiesKitTests check recorded issues with `withKnownIssue { … } matching:`, counting the matched issues and checking each one's comment and source location. Unless an AC says otherwise, `match` gets an explicit locale.
- AC-1 Given a received value equal to the `polish` entry's value, when `match` runs in `pl_PL`, then no issue is recorded and it returns `true`; the same for `english` in `en_GB` (BR-4).
- AC-2 Given `polish` and `english` entries, when `match` runs in `pl`, `pl_DE`, `en` and `en_US` with the value of the entry for the locale's language, then no issue is recorded; with the other language's value, one difference issue is recorded at the entry for the locale's language (BR-3, BR-5).
- AC-3 Given two structs that differ in one property, when `match` runs in `pl_PL`, then exactly one issue is recorded, at the `polish` entry's source location, its comment starts with `Found difference for pl:` and names that property, and it returns `true`; given two values with the same fields of a type whose `==` returns `false`, the comment's next lines are `Expected: …` and `Received: …` (BR-4, BR-5).
- AC-4 Given a failing `match` inside `#expect`, then exactly one issue is recorded in total (BR-4).
- AC-5 Given only `polish` and `english` entries, when `match` runs in `de_DE`, then one issue is recorded at the call site with `No value for language de (locale de_DE); entries: pl, en`, and it returns `true`; in `Locale(identifier: "")` the comment is `No value for language — (locale ); entries: pl, en`; with no entries in `pl_PL`, it is `No value for language pl (locale pl_PL); entries: —`; given only a `polish` entry in `en_GB`, it is `No value for language en (locale en_GB); entries: pl` (BR-6).
- AC-6 Given two `polish` entries with different values, when `match` runs in `pl_PL` with the first value, then one issue is recorded at the second entry's source location with `Duplicate value for language pl`, there is no difference issue, and nothing crashes; given three `polish` entries, the second and third each record one; given two `english` entries, when `match` runs in `pl_PL`, the second `english` entry records `Duplicate value for language en` (BR-7).
- AC-7 (removed, Q-8)
- AC-8 Given the same entries as an array and as a variadic list, then both overloads give the same outcome for AC-1, AC-3 and AC-5 (Data).
- AC-9 `TestLanguage.allCases` is `[polish, english]`, with codes `pl` and `en`, locales `pl_PL` and `en_GB`, and test descriptions `pl` and `en`; `LanguageMatch<String>` values can be passed as `@Test(arguments:)` (Data, BR-9).
- AC-10 (review) TestUtilitiesKit reads the process locale only as `match`'s default `.current` and never uses `Locale.autoupdatingCurrent`, `Locale.preferredLanguages`, `Bundle.preferredLocalizations` or `Bundle.main`; only test targets depend on it; Difference is pinned to exactly 1.1.0 (BR-1, BR-2).
- AC-11 The lint command (with `testutilitieskit_imports` allowing only Foundation, Testing and Difference), the tests command of BR-13 and the iOS build command for TestUtilitiesKit succeed with no warnings (BR-1, BR-10, BR-12, BR-13).
- AC-12 (review) The sources follow `CLAUDE.md` › Code style with a single `return true` in `match` and the one `// Workaround:` line above it, and hold no project headers, constants or earlier locales; `UtilitiesKit/CLAUDE.md`, the root `CLAUDE.md`, `.swiftlint.yml`, `.gitignore` and the workspace `.claude/settings.json` change as BR-12 says; `git check-ignore` reports the scheme as not ignored and the rest of `.swiftpm/` as ignored, and the scheme can be read under the workspace settings (BR-11, BR-12, BR-13).
- AC-13 Given an optional subject with entries `.polish(nil)` and `.english("Reminders")`, when `match` runs with `nil` in `pl_PL`, then no issue is recorded; with `nil` in `en_GB`, one difference issue is recorded at the `english` entry's source location (Data, BR-5).
- AC-14 (removed, Q-10)
- AC-15 (manual) Given the tests command of BR-13, then the result bundle lists the configurations Polish and English with every test in each (BR-13).
- AC-16 Given the tests command of BR-13, when a test matches the default locale's `{language code}_{region}` against `.polish(TestLanguage.polish.locale.identifier)` and `.english(TestLanguage.english.locale.identifier)` with no locale passed, then no issue is recorded in either configuration (Data, BR-2, BR-13).

## Open questions
- —

## Changelog
- 2026-10-27 Drafted from the user's LocaleMatch files and Difference; placement, test languages, match key, `true` with one issue, comments (Q-1–Q-5) (create-spec)
- 2026-10-27 English locale `en_GB` (Data, BR-3, AC-1, AC-2, AC-9, Q-6); Difference pinned to 1.1.0 (BR-1, AC-10, Q-7); `Optional.match` dropped, optionals through `Equatable.match` (Scope, Data, BR-8, AC-7, AC-13, Q-8); fallback when Difference gives no lines (BR-5, AC-3); locale without a language code (AC-5); duplicates per entry in every locale (BR-7, AC-6); observable AC-2; `Sendable` `LocaleMatch` (Data, AC-9); BR-10 and BR-11 cite `CLAUDE.md`; Commands owner (BR-12) (review-spec round 1)
- 2026-10-27 Source paths and `.swiftlint.yml` owner, imports checked by lint (Scope, BR-12, AC-10, AC-11, AC-12); single `return true` (BR-11, AC-12); no entries (BR-6, AC-5); Approved (review-spec revalidation)
- 2026-10-27 Implemented: plan `docs/plans/testing/test-utilities.md` (removed on reopen, in git at 0f83fdc), 0f83fdc..f93b778
- 2026-10-27 Reopened: `match` drops `locale`; language from `TestLanguage.current`, set by the `testLanguages` trait; entries for another language are skipped; no test plan configurations (Goal, Scope, Glossary, Data, BR-2, BR-3, BR-5, BR-6, BR-7, AC-1, AC-2, AC-5, AC-6, AC-9, AC-13, AC-14, Q-9); Draft
- 2026-10-27 Trait and `TestLanguage.current` dropped: `match`'s `locale` defaults to the process locale, set by Polish and English test plan configurations; language-code matching and the missing-language issue back; UtilitiesKit test plan run with `xcodebuild`; `LocaleMatch` renamed `LanguageMatch` (Goal, Scope, Glossary, Data, BR-2, BR-3, BR-5, BR-6, BR-7, BR-12, BR-13, AC-1–AC-3, AC-5, AC-6, AC-9–AC-15, Q-10–Q-12) (review-spec round 3)
- 2026-10-27 Committed scheme readable and not ignored: `.gitignore` re-includes each level, workspace `.claude/settings.json` deny narrowed (BR-12, BR-13, AC-12, Q-13); default-locale check automated as AC-16, AC-15 keeps the result bundle; Approved (review-spec round 4, revalidation)
