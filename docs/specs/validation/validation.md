# Validation
Level: index · Repo: UtilitiesKit · Module: UtilitiesKit

## Goal
Validation every form uses: a rule says what a valid input is, a validation result says whether the input passes, and a validator decides when a field's error shows, so no form invents its own timing.

## Glossary
| PL | EN | Meaning |
|---|---|---|
| Walidacja | Validation | Checking what the user enters against a rule and deciding when a field's error shows |

## Specs
| Spec | Level | Scope | Mockup | Status |
|---|---|---|---|---|
| [validation/validators](validators.md) | capability | Validation result, focus-aware validator, text rules (required, length) and composition; locale only when a rule is built | — | Approved |

## Later
- Rules that parse or format with a locale (amount, rate, account number), comparisons, decimal places and parsed values: each arrives with the first form needing it (validators Q-2)
