# Formatting
Level: index · Repo: UtilitiesKit · Module: UtilitiesKit

## Goal
Locale-aware text for the apps: dates, starting with the month title, and later amounts, produced by formatters configured with a locale, calendar and time zone, with a process fallback when a caller leaves them out.

## Glossary
| PL | EN | Meaning |
|---|---|---|
| Formatowanie | Formatting | Turning a value into display-ready text for a locale, a calendar and a time zone |
| Formater | Formatter | A value type configured once with a locale, calendar and time zone that produces text; no shared instance |

## Specs
| Spec | Level | Scope | Mockup | Status |
|---|---|---|---|---|
| [formatting/month-title](month-title.md) | capability | Month and year as one title in a locale, calendar and time zone, with a process fallback | — | Planned |

## Later
- Other date outputs (day, short date, date and time) and parsing date strings in several formats: each arrives with the first spec that needs it (month-title Q-1, Q-3)
- Amount formatting from a `Decimal` and an ISO 4217 code, and parsing amounts typed with a comma or a dot: the first screen that shows or edits an amount; `Money` stays in DataKit (month-title Q-1, Q-2)
