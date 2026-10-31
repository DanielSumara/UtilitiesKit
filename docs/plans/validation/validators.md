# Validators — implementation plan
Spec: UtilitiesKit/docs/specs/validation/validators.md
Repo: UtilitiesKit
Status: Done
Run base: c6e500a05c684032547c8f94718f55ca132ff981
Depends on: —

## Slices
### S1 — Core: validation result and rule
- ACs: AC-1, AC-12
- Area: UtilitiesKit/Sources/UtilitiesKit/Validation, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: —
- Skills: —
- Review: full
- Builds: `ValidationResult` (`Sources/UtilitiesKit/Validation/ValidationResult.swift`: `undetermined`, `valid`, `invalid(reason:)`, `isValid`, `reason`; `Equatable`, `Sendable`) and `ValidationRule<Input>` (`Sources/UtilitiesKit/Validation/ValidationRule.swift`: `init(_:)`, `reason(for:)`; `Sendable` for every input); tests `ValidationResultTests.swift`, `ValidationRuleTests.swift`
- Done when: tests `AC-1` and `AC-12` pass in both configurations of the test plan; lint clean; `UtilitiesKit` builds for iOS and macOS without warnings
- Manual ACs: —

### S2 — Core: text rules
- ACs: AC-3, AC-4
- Area: UtilitiesKit/Sources/UtilitiesKit/Validation, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: S1
- Skills: —
- Review: full
- Builds: `ValidationRule+Text.swift` with `required(message:)`, `length(_:message:)` and `length(atMost:message:)`; tests `ValidationRuleTextTests.swift`
- Done when: tests `AC-3a`, `AC-3b`, `AC-4a`–`AC-4c` pass in both configurations; lint clean; `UtilitiesKit` builds for iOS and macOS without warnings
- Manual ACs: —

### S3 — Core: composition
- ACs: AC-5, AC-6
- Area: UtilitiesKit/Sources/UtilitiesKit/Validation, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: S1, S2
- Skills: —
- Review: full
- Builds: `ValidationRule+Composition.swift` with `allOf(_:)` and `ifPresent(_:)`; tests `ValidationRuleCompositionTests.swift`
- Done when: tests `AC-5a`, `AC-5b`, `AC-6a`, `AC-6b` pass in both configurations; lint clean; `UtilitiesKit` builds for iOS and macOS without warnings
- Manual ACs: —

### S4 — Core: validator timing
- ACs: AC-2
- Area: UtilitiesKit/Sources/UtilitiesKit/Validation, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: S1, S2, S3
- Skills: —
- Review: full
- Builds: `Validator<Input>` (`Validator.swift`: `init(rule:input:)`, settable `input` and `rule`, read-only `result`, `mutating force()`; `Sendable` where `Input: Sendable`) deciding BR-2 to BR-5 and BR-7 without focus; tests `ValidatorTests.swift`
- Done when: tests `AC-2a`–`AC-2g` pass in both configurations; lint clean; `UtilitiesKit` builds for iOS and macOS without warnings
- Manual ACs: —

### S5 — Core: validator focus
- ACs: AC-7, AC-8
- Area: UtilitiesKit/Sources/UtilitiesKit/Validation, UtilitiesKit/Tests/UtilitiesKitTests
- Depends on: S4
- Skills: —
- Review: full
- Builds: settable `hasFocus` on `Validator`, `false` at first, forcing validation when focus leaves after an input since it entered (BR-6, BR-12); focus tests added to `ValidatorTests.swift`
- Done when: tests `AC-7a`–`AC-7g` pass in both configurations; AC-8 reviewed against Data (public shape, `Sendable` conditions, no `Locale` parameter on `reason(for:)`, `force()` or the validator, no initial focus); lint clean; `UtilitiesKit` builds for iOS and macOS without warnings
- Manual ACs: —

### S6 — Owners and verification
- ACs: AC-9, AC-10, AC-11, AC-13
- Area: UtilitiesKit/README.md, UtilitiesKit/CLAUDE.md, UtilitiesKit/docs/specs/README.md, UtilitiesKit/docs/specs/validation/validation.md; review scope also UtilitiesKit/Sources/UtilitiesKit/Validation (AC-9, AC-11)
- Depends on: S1, S2, S3, S4, S5
- Skills: —
- Review: diff-only
- Builds: —
- Done when: README status line names the validators; `CLAUDE.md` › Rules says a validator's rule takes an injected locale when built, defaulting to `.autoupdatingCurrent`, and copy comes from `String(localized:)`, never a passed locale; the specs README row and the validation feature index row carry the spec's status; AC-9 reviewed (Foundation-only imports, no copy, String Catalog or resource, no `Locale.current` or `Locale.autoupdatingCurrent` read, `Package.swift` unchanged); AC-10: lint, both test-plan configurations and the `UtilitiesKit` iOS build succeed with no warnings and the tests run UtilitiesKitTests; AC-11 reviewed (one type per file, file named after its type or the type it extends, no comments)
- Manual ACs: —

## AC coverage
| AC | Slice | Verified by |
|---|---|---|
| AC-1 | S1 | test `AC-1` |
| AC-2 | S4 | tests `AC-2a`–`AC-2g` |
| AC-3 | S2 | tests `AC-3a`, `AC-3b` |
| AC-4 | S2 | tests `AC-4a`–`AC-4c` |
| AC-5 | S3 | tests `AC-5a`, `AC-5b` |
| AC-6 | S3 | tests `AC-6a`, `AC-6b` |
| AC-7 | S5 | tests `AC-7a`–`AC-7g` |
| AC-8 | S5 | review (public shape against Data, `Sendable`, no `Locale`, no initial focus) |
| AC-9 | S6 | review (grep for imports, copy, catalog, `Locale.current`/`.autoupdatingCurrent`, `Package.swift`) |
| AC-10 | S6 | lint, both test-plan configurations and `UtilitiesKit` iOS build, no warnings |
| AC-11 | S6 | review (one type per file, file names, no comments) |
| AC-12 | S1 | test `AC-12` |
| AC-13 | S6 | review (owners and index rows) |

## Manual verification
- — Every AC is automated or code review.

## Out of scope
- Binding a rule and a validator to a `DK.FormField`, field lists, the primary action forcing visible fields, focus in forms and hidden fields: HomeBudgetApps forms/validated-fields
- Rules beyond text: comparisons, `parsed`, decimal places, amount, rate and account number — each arrives with the first spec that needs it (Q-2)
- The reminder form's name rules and its messages: HomeBudgetApps reminders/configure-reminders/reminder-form
- Checks against stored data, e.g. a unique name: Models through DataKit and the feature spec that needs it
- User-facing copy, a String Catalog or resources in UtilitiesKit: every rule takes the form's message (BR-9)
- A release tag and `CHANGELOG.md`

## Progress
| Slice | Status | Base | Head | Review |
|---|---|---|---|---|
| S1 | Done | c6e500a | dd5f75d | 0 fixed / 0 rejected |
| S2 | Done | dd5f75d | c03124f | 0 fixed / 0 rejected |
| S3 | Done | c03124f | 859d4db | 0 fixed / 0 rejected |
| S4 | Done | 859d4db | 3b234e9 | 0 fixed / 0 rejected |
| S5 | Done | 3b234e9 | 86321da | 0 fixed / 0 rejected |
| S6 | Done | 86321da | 9ab05a9 | 0 fixed / 0 rejected |

## Open questions
- None
