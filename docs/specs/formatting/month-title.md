# Month title
Status: Planned · Level: capability · Repo: UtilitiesKit · Feature: formatting · Module or target: UtilitiesKit, UtilitiesKitTests · Depends on: —

## Goal
A month and its year as one title in a locale, calendar and time zone: "Październik 2026" in Polish, "October 2026" in English, "2026年10月" in Japanese. One preconfigured `DisplayDateFormatter` produces it and later date outputs join it (Q-4); the title is either right or absent, never a neighbouring month (BR-4). A caller may leave out the locale, calendar or time zone, and the formatter falls back to `.autoupdatingCurrent` (Q-6).

## Scope
- In:
  - `DisplayDateFormatter`: one formatter configured with a `Locale`, a `Calendar` and a `TimeZone`, each defaulting to `.autoupdatingCurrent`
  - Its month title output: the wide standalone month name and the year, in the locale's order, the first character capitalized
  - Swift Testing tests for the public API in UtilitiesKitTests and SwiftLint for the new sources
  - The singleton rule and its lint: a singleton value may be passed or default a parameter or property, but members may not be called on it (root `CLAUDE.md` › Architecture rules, `UtilitiesKit/CLAUDE.md` › Rules, `.swiftlint.yml` in UtilitiesKit, HomeBudgetApps and DesignKit)
  - Owners: `UtilitiesKit/README.md`, `docs/specs/README.md` and `docs/specs/formatting/formatting.md`
- Out:
  - Other date outputs (day, short date, date and time), a generic `stringFrom`/format API, and parsing date strings in several formats: the first spec that needs each (Q-1, Q-3, Q-5)
  - Amount formatting, parsing amounts typed with a comma or a dot, and any money or amount type in UtilitiesKit: the first screen that shows or edits an amount; `Money` stays in DataKit (Q-1, Q-2)
  - The Schedule's header, its copy and its mockup: HomeBudgetApps reminders/schedule-reminders/list
  - User-facing copy, a String Catalog or resources: the title comes from locale data, not copy
  - A release tag and `CHANGELOG.md`

## Glossary
| PL | EN | Meaning |
|---|---|---|
| Miesiąc | Month | A calendar month named by a year and a number from 1 to 12 |
| Tytuł miesiąca | Month title | A month and its year as one title in a locale, e.g. "Październik 2026" |
| Formater dat | Date formatter | The preconfigured `DisplayDateFormatter` that turns date values into display text for one locale, calendar and time zone |
| Samodzielna nazwa miesiąca | Standalone month name | The month name used on its own, nominative in Polish ("październik"), not the genitive used inside a date ("października") |

## User stories
- US-1 As a user I want the Schedule's header to name the shown month in my language, e.g. "Październik 2026", so that I know which month I'm looking at.
- US-2 As a Core developer I want one date formatter configured once with a locale, calendar and time zone so that screens don't format dates themselves, the injected values still decide the text, and a preview or test can omit them.
- US-3 As a user I want a month title that is either right or absent, so that a bad month can never show the neighbouring month.

## Data
- `DisplayDateFormatter` (public struct, `Sendable`): one preconfigured date formatter; holds a locale, a calendar and a time zone and no other state
  - `init(locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent, timeZone: TimeZone = .autoupdatingCurrent)` — the app's Core passes the injected values; a caller may leave any of them out and take the process fallback
  - `monthTitle(year: Int, month: Int) -> String?` — the month title; both values are required; `nil` when `month` is outside 1...12 or `year` outside 1...9999 (BR-4)
- Output: the locale's wide month name in its standalone form and the year, in the order and with the separators the locale uses; the first character capitalized in the formatter's locale (BR-2, BR-3)
- Later outputs (day, short date) join `DisplayDateFormatter` as their own methods; none in this increment (Q-1, Q-5)
- Use: `DisplayDateFormatter(locale: locale, calendar: calendar, timeZone: timeZone).monthTitle(year: 2026, month: 10)` gives "Październik 2026"; `DisplayDateFormatter().monthTitle(year: 2026, month: 10)` takes the process fallback

## Rules
- BR-1 `DisplayDateFormatter` is a value type configured once with a locale, a calendar and a time zone, each falling back to `.autoupdatingCurrent` when omitted. It reads only those three values: no `Date()`, no process locale, calendar or time zone read inside its methods, and no shared or static formatter instance.
- BR-2 The title is the wide standalone month name of the formatter's calendar in its locale and the year, in the order and with the separators the locale uses: "Październik 2026" in pl_PL, "October 2026" in en_GB, "2026年10月" in ja_JP. The parts are never concatenated in a fixed order, and the month name never comes from copy.
- BR-3 The title's first character is capitalized in the formatter's locale; the rest of the month name stays as the locale writes it. A title starting with a non-letter is unchanged. So Polish "październik 2026" becomes "Październik 2026", while English and Japanese already start as their locale writes them (Q-1).
- BR-4 The title names exactly the requested year and month, whatever the current time and the time zone: it never rolls into a neighbouring month. A month outside 1...12 or a year outside 1...9999 gives `nil`, with no text, no crash and no fallback.
- BR-5 The same formatter gives the same title for the same year and month on every call, and the values it was built with decide it: one built with explicit values ignores the process language and time zone, while one built with a fallback follows the process's autoupdating locale, calendar and time zone.
- BR-6 The sources import Foundation only, live under `Sources/UtilitiesKit/Formatting`, and follow the repo rules: one type per file, a file named after its type, public access on the product's API, and no comments.
- BR-7 No package dependency, product, resource or localization is added; `Package.swift` keeps its products, targets and dependencies unchanged. UtilitiesKit holds no domain type: the title takes integers, and no money, amount or day type enters the package (Q-2).
- BR-8 Owners are updated in the same change: `UtilitiesKit/README.md`'s status line names `DisplayDateFormatter`; `UtilitiesKit/CLAUDE.md` › Rules says date formatters take an injected locale, calendar and time zone, each defaulting to `.autoupdatingCurrent`; root `CLAUDE.md` › Architecture rules says a singleton may be passed or stored as a value but never have members called on it, and no root line still forbids `.current` as a stored value; `.swiftlint.yml` in UtilitiesKit, HomeBudgetApps and DesignKit carries the matching `no_singletons` message, and `injected_time_and_locale` becomes `injected_clock` checking only `Date()` in UtilitiesKit and HomeBudgetApps; `docs/specs/README.md` and `docs/specs/formatting/formatting.md` carry the formatting/month-title row in sync with the spec's status.

## Screens
- HomeBudgetApps reminders/schedule-reminders/list: the Schedule's header shows the month title (its BR-4, AC-5).

## Acceptance criteria
A formatter is Polish (pl_PL), Gregorian and Europe/Warsaw unless a check gives another; the year and month are passed explicitly unless a check says otherwise.

- AC-1 Given the Polish formatter, when asked for October 2026, then the title is "Październik 2026" (BR-2, BR-3).
- AC-2 Given a formatter for en_GB, when asked for October 2026, then the title is "October 2026"; given en_US, then it is "October 2026" (BR-2, BR-3).
- AC-3 Given a formatter for ja_JP, when asked for October 2026, then the title is "2026年10月": the year first, as the locale orders it (BR-2).
- AC-4 Given the Polish formatter, when asked for January, February, October and December 2026, then the titles are "Styczeń 2026", "Luty 2026", "Październik 2026" and "Grudzień 2026"; when asked for each month 1...12, then every title is non-empty and starts with a capital letter (BR-2, BR-3).
- AC-5 Given the Polish formatter, when asked for month 0 or 13 of 2026, then the title is `nil`, never "Grudzień 2025" or "Styczeń 2027"; when asked for year 0 or 10000 with month 10, then the title is `nil` (BR-4).
- AC-6 Given `DisplayDateFormatter()` with no arguments, when asked for October 2026, then the title matches the process language: "Październik 2026" when `Locale.current`'s language is Polish, "October 2026" when it is English (BR-1, BR-5).
- AC-7 (code review) Given `DisplayDateFormatter`, then it is a public `Sendable` struct with `init(locale:calendar:timeZone:)` defaulting each parameter to `.autoupdatingCurrent` and `monthTitle(year:month:) -> String?` as Data defines, and it has no static or shared instance (Data, BR-1).
- AC-8 (code review) Given this increment's sources, then they import Foundation only, hold no copy, String Catalog or resource, and read no `Date()`, `Locale.current`, `Calendar.current` or `TimeZone.current`; no package dependency or product is added (BR-1, BR-6, BR-7).
- AC-9 The lint command, the tests command (Polish and English configurations) and the `UtilitiesKit` iOS build command from `UtilitiesKit/CLAUDE.md` › Commands succeed with no warnings, and the tests run UtilitiesKitTests (BR-6, BR-7).
- AC-10 (code review) Given the package's sources, then they follow `CLAUDE.md` › Code style with one type per file, a file named after its type, and no comments (BR-6).
- AC-11 (code review) Given `UtilitiesKit/README.md`, then its status line names `DisplayDateFormatter`; given `UtilitiesKit/CLAUDE.md` › Rules, then date formatters take the injected locale, calendar and time zone with `.autoupdatingCurrent` fallbacks; given root `CLAUDE.md` › Architecture rules, then a singleton may be passed or stored but not have its members called, and no line forbids `.current` as a stored value; given `docs/specs/README.md` and `docs/specs/formatting/formatting.md`, then the formatting/month-title row carries the spec's status (BR-8).
- AC-12 (code review) Given UtilitiesKit's and HomeBudgetApps' lint configuration, then `DisplayDateFormatter(locale: .autoupdatingCurrent)`, `DisplayDateFormatter(locale: Locale.autoupdatingCurrent)` and `private let locale: Locale = .current` pass; `Locale.current.currencySymbol(...)` fails `no_singletons`; `Date()` fails `injected_clock`; all three `.swiftlint.yml` carry the same `no_singletons` message (BR-8).
- AC-13 Given the Polish formatter with time zone Pacific/Kiritimati (UTC+14), and again with Pacific/Pago_Pago (UTC−11), when asked for October 2026, then the title is "Październik 2026", whatever the process time zone (BR-4, BR-5).

## Open questions
- —

## Changelog
- 2026-11-01 Drafted from the placeholder: month title only in one preconfigured formatter, the first character capitalized; date parsing and amount formatting deferred, `Money` stays in DataKit, spec id unchanged (Q-1, Q-2, Q-3) (create-spec)
- 2026-11-01 Revised in session: `DisplayDateFormatter` with `monthTitle(year:month:)`, year and month required, no day or time components; `.autoupdatingCurrent` fallbacks for locale, calendar and time zone; singleton values allowed as arguments, parameter defaults and properties, member access still prohibited, with the lint rule and owners updated (Q-4, Q-5, Q-6) (create-spec)
- 2026-11-01 Revalidated and approved: the formatter's calendar named as the month's source (BR-2); the root `CLAUDE.md` owner split so the formatter default stays in UtilitiesKit/CLAUDE.md, the singleton rule stays in root and no root line still forbids `.current` as a stored value (BR-8, AC-11); the lint check named per repo with the three `no_singletons` messages in sync (AC-12) (review round 1)
- 2026-11-01 AC-13 added: the title stays in the requested month in time zones far from the process one (BR-4, BR-5); revalidated, approved and planned again with AC-13 in S3 (review round 2)
