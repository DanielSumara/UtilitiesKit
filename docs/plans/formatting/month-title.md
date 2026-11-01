# Month title — implementation plan
Spec: UtilitiesKit/docs/specs/formatting/month-title.md
Repo: UtilitiesKit
Status: Done
Run base: a3ce5636a4584fee05589c137c13ed9b1835ae66
Depends on: —

## Slices
### S1 — Core: formatter and locale-ordered title
- ACs: AC-2, AC-3, AC-7
- Area: UtilitiesKit/Sources/UtilitiesKit/Formatting, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: —
- Skills: —
- Review: full
- Builds: `DisplayDateFormatter` (`Sources/UtilitiesKit/Formatting/DisplayDateFormatter.swift`: public `Sendable` struct holding only a `Locale`, a `Calendar` and a `TimeZone`; `init(locale:calendar:timeZone:)` with every parameter defaulting to `.autoupdatingCurrent`; `monthTitle(year:month:) -> String?` building the components in its own calendar and time zone and returning the wide month name and the year in the order and with the separators the locale uses, never a fixed concatenation; no static or shared instance); tests `DisplayDateFormatterTests.swift` for en_GB, en_US and ja_JP October 2026
- Done when: tests `AC-2`, `AC-3` pass in both configurations of the test plan `UtilitiesKit.xctestplan`; AC-7 reviewed against Data (public `Sendable` struct, the exact init and method, no static or shared instance); lint (`swiftlint lint --strict --quiet`) clean; `UtilitiesKit` builds for iOS and macOS with no warnings
- Manual ACs: —

### S2 — Core: standalone month name and capitalized first character
- ACs: AC-1, AC-4
- Area: UtilitiesKit/Sources/UtilitiesKit/Formatting, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: S1
- Skills: —
- Review: full
- Builds: the wide standalone month name of `DisplayDateFormatter`'s calendar in its locale — nominative Polish "październik", not the genitive "października" (BR-2, Glossary) — with the first character capitalized in the formatter's locale and the rest left as the locale writes it, a title starting with a non-letter unchanged (BR-3); `monthTitle(year:month:)` behaviour from S1 unchanged; tests in `DisplayDateFormatterTests.swift` for the four named Polish months and for all months 1...12
- Done when: tests `AC-1`, `AC-4` pass in both configurations; the en_GB, en_US and ja_JP tests of S1 still pass; lint clean; `UtilitiesKit` builds for iOS and macOS with no warnings
- Manual ACs: —

### S3 — Core: bounds, time zones and process fallback
- ACs: AC-5, AC-6, AC-13
- Area: UtilitiesKit/Sources/UtilitiesKit/Formatting, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: S1, S2
- Skills: —
- Review: full
- Builds: a bounds guard in `monthTitle(year:month:)` returning `nil` for a month outside 1...12 or a year outside 1...9999 before any date arithmetic, so the title never rolls into the neighbouring month (BR-4); `DisplayDateFormatter()` with no arguments taking the `.autoupdatingCurrent` fallback of all three values (BR-1, BR-5); tests in `DisplayDateFormatterTests.swift` for months 0 and 13, years 0 and 10000, and for Pacific/Kiritimati and Pacific/Pago_Pago October 2026 (the date built and formatted in the formatter's own time zone, BR-4), and for the no-argument formatter compared against the process language read as a stored `let locale: Locale = .current` (UtilitiesKitTests links `UtilitiesKit` only, so no TestUtilitiesKit helper and no `Package.swift` change)
- Done when: tests `AC-5`, `AC-6`, `AC-13` pass in both configurations (Polish configuration expects "Październik 2026", English "October 2026"); AC-1 to AC-4 tests still pass; lint clean; `UtilitiesKit` builds for iOS and macOS with no warnings
- Manual ACs: —

### S4 — Owners and verification
- ACs: AC-8, AC-9, AC-10, AC-11, AC-12
- Area: UtilitiesKit/README.md, UtilitiesKit/CLAUDE.md, UtilitiesKit/docs/specs/README.md, UtilitiesKit/docs/specs/formatting/formatting.md, UtilitiesKit/.swiftlint.yml; review scope also the root CLAUDE.md, HomeBudgetApps/.swiftlint.yml, DesignKit/.swiftlint.yml and UtilitiesKit/Sources/UtilitiesKit/Formatting (AC-8, AC-10, AC-12)
- Depends on: S1, S2, S3
- Skills: —
- Review: diff-only
- Builds: `UtilitiesKit/README.md`'s status line names `DisplayDateFormatter`; the rule lines in both `CLAUDE.md` and the three `.swiftlint.yml` already carry BR-8's wording (committed with the spec), so they are only reviewed
- Done when: `UtilitiesKit/README.md`'s status line names `DisplayDateFormatter`; `UtilitiesKit/CLAUDE.md` › Rules and the root `CLAUDE.md` › Architecture rules match AC-11 (date formatters take an injected locale, calendar and time zone with `.autoupdatingCurrent` fallbacks in the kit; the root rule allows a singleton as a passed or stored value and never as a member call, with no line forbidding `.current` as a stored value); the `docs/specs/README.md` row and the `formatting/formatting.md` row carry the spec's status, kept in sync; AC-12 reviewed (the same `no_singletons` message in all three `.swiftlint.yml`, `injected_clock` checking only `Date()` in UtilitiesKit and HomeBudgetApps, the listed pass and fail probes); AC-8 reviewed (Foundation-only imports in the new sources, no copy, String Catalog or resource, no `Date()`, `Locale.current`, `Calendar.current` or `TimeZone.current` read, `Package.swift` unchanged); AC-10 reviewed (one type per file, file named after its type, no comments); AC-9: lint, the Polish and English test-plan configurations and the `UtilitiesKit` and `TestUtilitiesKit` iOS builds succeed with no warnings and the tests run UtilitiesKitTests
- Manual ACs: —

## AC coverage
| AC | Slice | Verified by |
|---|---|---|
| AC-1 | S2 | tests `AC-1` (Polish October 2026 "Październik 2026") |
| AC-2 | S1 | tests `AC-2` (en_GB and en_US October 2026) |
| AC-3 | S1 | test `AC-3` (ja_JP "2026年10月") |
| AC-4 | S2 | tests `AC-4` (January, February, October, December; months 1...12 non-empty, capital-initial) |
| AC-5 | S3 | tests `AC-5` (months 0 and 13, years 0 and 10000 give `nil`) |
| AC-6 | S3 | test `AC-6` (no-argument formatter follows the process language) |
| AC-7 | S1 | review (public `Sendable` struct, init with `.autoupdatingCurrent` defaults, `monthTitle(year:month:) -> String?`, no static or shared instance) |
| AC-8 | S4 | review (grep for imports, copy and catalogs, `Date()`, `.current` reads, `Package.swift`) |
| AC-9 | S4 | lint, Polish and English test-plan configurations, `UtilitiesKit` and `TestUtilitiesKit` iOS builds, no warnings |
| AC-10 | S4 | review (one type per file, file names, no comments) |
| AC-11 | S4 | review (README status line, both CLAUDE.md rules, both index rows) |
| AC-12 | S4 | review (three `no_singletons` messages, `injected_clock` scope, the named pass and fail probes) |
| AC-13 | S3 | tests `AC-13` (Pacific/Kiritimati and Pacific/Pago_Pago October 2026 "Październik 2026") |

## Manual verification
- — Every AC is automated or code review.

## Out of scope
- Other date outputs (day, short date, date and time), a generic `stringFrom`/format API and parsing date strings in several formats: the first spec that needs each (Q-1, Q-3, Q-5)
- Amount formatting, parsing amounts typed with a comma or a dot, and any money or amount type in UtilitiesKit: the first screen that shows or edits an amount; `Money` stays in DataKit (Q-1, Q-2)
- The Schedule's header, its copy and its mockup: HomeBudgetApps reminders/schedule-reminders/list
- User-facing copy, a String Catalog or resources: the title comes from locale data, not copy
- A release tag and `CHANGELOG.md`

## Progress
| Slice | Status | Base | Head | Review |
|---|---|---|---|---|
| S1 | Done | a3ce563 | 5b1724b | 0 fixed / 0 rejected |
| S2 | Done | 5b1724b | 684dc91 | 0 fixed / 0 rejected |
| S3 | Done | 684dc91 | 1ed8dee | 0 fixed / 0 rejected |
| S4 | Done | 1ed8dee | f717a44 | 0 fixed / 0 rejected |

## Open questions
- None
