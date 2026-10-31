# Validators
Status: Planned · Level: capability · Repo: UtilitiesKit · Feature: validation · Module or target: UtilitiesKit, UtilitiesKitTests · Depends on: —

## Goal
Give every form one way to validate what the user enters. A rule says what a valid input is and fails with the message the form gives it; a validation result is undetermined, valid, or invalid with that one message; a validator decides when a field's error shows: a correct input is valid at once, an error only after forced validation, never as the user types. Foundation only, no DesignKit, no copy; no validation call takes a `Locale`, and a rule that needs one takes it once when built (BR-9).

## Scope
- In:
  - `ValidationResult`: undetermined, valid, invalid with a reason
  - `ValidationRule<Input>`: a check giving the form's message when the input fails, plus `allOf` and `ifPresent`
  - Text rules: `required`, `length(_ range:)` and `length(atMost:)`
  - `Validator<Input>`: the field's rule and current input, forced validation, and keyboard focus
  - Swift Testing tests for the public API in UtilitiesKitTests and SwiftLint for the new sources
  - Owners: `UtilitiesKit/README.md`, `UtilitiesKit/CLAUDE.md` › Rules, `docs/specs/README.md` and `docs/specs/validation/validation.md`
- Out:
  - Binding a rule and a validator to a `DK.FormField`, field lists, the primary action forcing visible fields, focus in forms and hidden fields: HomeBudgetApps forms/validated-fields
  - Rules beyond text: comparisons, `parsed`, decimal places, amount, rate and account number — each arrives with the first spec that needs it (Q-2)
  - The reminder form's name rules and its messages: HomeBudgetApps reminders/configure-reminders/reminder-form
  - Checks against stored data, e.g. a unique name: Models through DataKit and the feature spec that needs it
  - User-facing copy, a String Catalog or resources in UtilitiesKit: every rule takes the form's message (BR-9)
  - A release tag and `CHANGELOG.md`

## Glossary
| PL | EN | Meaning |
|---|---|---|
| Walidator | Validator | Decides one field's validation result from its input and rule, and forces its validation when keyboard focus leaves the field after it took an input |
| Reguła | Rule | What a valid input is, e.g. required text or 1–80 characters, with the message the form gives for an input that fails it; rules combine into one |
| Wynik walidacji | Validation result | Undetermined, valid, or invalid with a reason |
| Wymuszona walidacja | Forced validation | Request to decide a field's input now and show its error: when keyboard focus leaves the field after it took an input, or when the form's primary action is chosen |
| Powód | Reason | Why an input is invalid: the message of the rule it failed, which the form shows as the field's error |

## User stories
- US-1 As a user I want an error to show only once I'm done with my input, when I leave the field or choose Add or Save, and to go as soon as I correct it, so that a form doesn't flash errors at me while I type.
- US-2 As a Core developer I want one validation mechanism in UtilitiesKit so that every form validates and shows errors the same way.
- US-3 As a user I want each error to say what to fix in that field, e.g. that a name is required, so that I can correct it without guessing.
- US-4 As a UtilitiesKit client I want to give a rule its locale once, when I build it, so that validating a value takes no locale, a later rule that parses or formats follows the system's current locale by default, and no locale ever chooses copy.

## Data
- `ValidationResult` (public enum, `Equatable`, `Sendable`): `undetermined`, `valid`, `invalid(reason: String)`
  - `isValid`: `Bool` — `true` only for `valid`
  - `reason`: `String?` — the reason for `invalid`, `nil` otherwise
- `ValidationRule<Input>` (public struct, `Sendable`): what a valid input of one type is; holds no state
  - `init(_ check: @escaping @Sendable (Input) -> String?)` — a feature may define its own rule
  - `reason(for input: Input) -> String?` — the form's message when the input fails, `nil` when it passes
  - a rule added by a later spec that needs a `Locale`, e.g. to parse or format a number, takes it in its factory method when the form builds it, defaulting to `.autoupdatingCurrent`; the locale never selects copy (BR-9, Q-1)
- UtilitiesKit offers these rules, as static functions on `ValidationRule`:
  - `static func required(message: String) -> ValidationRule<String>` — fails when the text is empty (BR-10)
  - `static func length(_ range: ClosedRange<Int>, message: String) -> ValidationRule<String>` — fails when its length is outside the range (BR-11)
  - `static func length(atMost maximum: Int, message: String) -> ValidationRule<String>` — fails when it is longer than `maximum` (BR-11)
  - `static func allOf(_ rules: [ValidationRule<Input>]) -> ValidationRule<Input>` — fails when any of its rules fails, in order (BR-8)
  - `static func ifPresent<Wrapped>(_ rule: ValidationRule<Wrapped>) -> ValidationRule<Wrapped?>` — passes an absent value; fails when the value is present and its rule fails (BR-8)

- `Validator<Input>` (public struct, `Sendable` where `Input: Sendable`): one per field
  - `result: ValidationResult` — read-only; the field's current result
  - `input: Input` — settable; each change is decided as BR-2 to BR-4 say, and counts as an input while the field has focus (BR-6)
  - `rule: ValidationRule<Input>` — settable; each change is decided as BR-2 to BR-4 say
  - `hasFocus: Bool` — settable, `false` at first; leaving focus after an input forces validation (BR-6)
  - `init(rule: ValidationRule<Input>, input: Input)`
  - `mutating func force()` — decides the current input now (BR-4)
- Use: a form builds its rule from its own copy, e.g. `Validator(rule: .allOf([.required(message: requiredMessage), .length(atMost: 80, message: tooLongMessage)]), input: name)`, and passes the validator the field's input and focus changes.

## Rules
- BR-1 Deciding a field's input against its rule gives valid when the input passes, otherwise invalid with the rule's reason; a result is valid only for `valid` and carries a reason only for `invalid`; BR-2 to BR-7 say when a validator decides.
- BR-2 A valid input is valid at once, so a shown error disappears as soon as the input is correct.
- BR-3 An invalid input is undetermined, showing no error, until the field's validation is forced, so nothing flashes while the user types ("1" on the way to "123"), also when they edit a valid value.
- BR-4 Forcing a field's validation decides its current input: valid, or invalid with its reason. An invalid field stays invalid while its input is invalid, its reason following the input (e.g. another rule fails instead); once its input is valid, a later invalid input is undetermined again until the next force.
- BR-5 A validator starts from the field's input when the form opens, absent when the field has no value: valid, or undetermined; so forcing an untouched field, e.g. an empty name, shows its error.
- BR-6 Validation is forced:
  - by the validator, when keyboard focus leaves its field after it took an input since focus last entered the field: any input counts, also one undone before leaving ("a" typed, then deleted) and one equal to the last. Inputs taken while the field doesn't have focus, and new rules (BR-7), don't count.
  - by the form, when the user chooses its primary action (e.g. Add, Save); how a form forces its fields is `HomeBudgetApps forms/validated-fields`.
- BR-7 A field whose rule depends on other values gets its updated rule whenever they change and is decided again as BR-2 to BR-4 say: valid at once; invalid with the new reason when it was invalid; otherwise undetermined. So its error shows at once only when it already shows one.
- BR-8 An invalid input has one reason:
  - a rule that fails gives its message
  - `allOf` fails with the reason of the first of its rules, in their order, that fails
  - `ifPresent` passes an absent value without checking its rule, and fails a present one with its rule's reason
- BR-9 A form gives each rule its message, display-ready in the app locale from the form's own copy, made with `String(localized:)`; UtilitiesKit has no messages, String Catalog or resources of its own. No validation call takes a `Locale`: `reason(for:)`, `force()` and a validator take none. A rule added by a later spec that needs a locale, e.g. to parse or format a number, takes it once when the form builds the rule, as a parameter defaulting to `.autoupdatingCurrent`; the locale never selects copy, so every message follows the app's language, not the rule's locale (Q-1).
- BR-10 Rules check the input as given: a form that trims (e.g. a name) validates the trimmed text, and `" "` has one character. `required` fails only empty text, so whether whitespace-only text is valid is the form's trimming decision.
- BR-11 Length counts characters as the user sees them: `"👍🏽"`, `"ł"`, `"é"` and `"e"` followed by U+0301 (combining acute accent) are one character each, so a form's character count agrees with the rule.
- BR-12 Focus that enters and leaves a field without an input since it entered forces nothing and keeps the current result. An input taken while the field doesn't have focus doesn't count as an input for a later focus leaving.
- BR-13 The sources import Foundation only, live under `Sources/UtilitiesKit/Validation`, and follow the repo rules: one type per file, a file named after its type or the type it extends, public access on the product's API, and no comments.
- BR-14 No package dependency, product, resource or localization is added; `Package.swift` keeps its products, targets and dependencies unchanged.
- BR-15 Owners are updated in the same change: `UtilitiesKit/README.md`'s status line names the validators; `UtilitiesKit/CLAUDE.md` › Rules says formatters, parsers and validators take an injected locale — a validator's rule takes it when it is built, defaulting to `.autoupdatingCurrent` — and that copy comes from `String(localized:)`, never from a passed locale (Q-1); `docs/specs/README.md` and `docs/specs/validation/validation.md` carry the validation/validators row in sync with the spec's status.

## Screens
- HomeBudgetApps forms/validated-fields: binds a rule and its validator to a `DK.FormField`, and forces visible fields on the primary action.
- HomeBudgetApps reminders/configure-reminders/reminder-form: validates the reminder's name with these rules.

## Acceptance criteria
Rules fail with the message "Błąd" unless a check gives another in parentheses, e.g. `required` ("A"). A validator check's rule is 3 to 10 characters unless it gives another, and its inputs and focus changes follow each other in the order given. Tests cite an AC with lettered checks per check (e.g. AC-2a). Tests pass in both language configurations of the UtilitiesKit test plan; a rule that takes a locale gets an explicit one in its tests.

Validation result
- AC-1 Given a valid result, then it is valid with no reason; given an undetermined one, then it isn't valid and has no reason; given an invalid one with the reason "A", then it isn't valid and its reason is "A" (Data, BR-1).

Validator timing
- AC-2 (BR-2 to BR-5, BR-7):
  - a) Given it starts from "", then it is undetermined; when the input becomes "1" and then "12", it stays undetermined; when it becomes "123", it is valid. Given it starts from "", when its validation is forced, then it is invalid with "Błąd".
  - b) Given it is valid with "123", when the input becomes "12", then it is undetermined.
  - c) Given "12", when its validation is forced, then it is invalid with "Błąd"; when the input becomes "1", it stays invalid; when it becomes "123", it is valid; when it becomes "12" again, it is undetermined.
  - d) Given it starts from "123", then it is valid; when its validation is forced, it stays valid; when the input becomes "12", it is undetermined.
  - e) Given a rule of `allOf` 3 to 10 characters ("A") and at most 5 ("B") and the input "12", when its validation is forced, then it is invalid with "A"; when the input becomes "123456", it is invalid with "B".
  - f) Given "12" invalid after a force, when the rule becomes 2 to 10 characters, then it is valid; when it becomes 3 to 10 again, it is undetermined. Given "12" valid with 2 to 10 characters, when the rule becomes 3 to 10, then it is undetermined. Given "1" invalid after a force with 3 to 10 characters ("A"), when the rule becomes 4 to 10 ("B"), then it is invalid with "B".
  - g) Given `ifPresent` of 3 to 10 characters, starting absent, then it is valid; when the input becomes "12", it is undetermined; when its validation is forced, it is invalid with "Błąd".

Text rules
- AC-3 `required` (BR-10):
  - a) Given `required` ("A"), then "" fails with "A", and " ", "a" and "abc" pass.
  - b) Given `allOf` of `required` ("A") and at most 3 characters ("B"), then "" fails with "A", "abcd" fails with "B", and "abc" passes.
- AC-4 Length (BR-11):
  - a) Given 1 to 80 characters, then "" and 81 characters fail, and " ", "OC" and 80 characters pass.
  - b) Given at most 500 characters, then "" and 500 characters pass and 501 fail.
  - c) Given at most 1 character, then "👍🏽", "ł", "é" and "e" followed by U+0301 pass, and "ab" fails.

Composition
- AC-5 `allOf` (BR-8), of 3 to 5 characters ("A") and at most 4 characters ("B"):
  - a) Given "abcde", which fails only "B", then it fails with "B"; given "abcdef", which fails both, then it fails with "A".
  - b) Given "abcd", then it passes.
- AC-6 `ifPresent` (BR-8):
  - a) Given `ifPresent` of `required` ("A"), then an absent value passes, "" fails with "A" and "abc" passes.
  - b) Given `ifPresent` of `allOf` of `required` ("A") and at most 3 characters ("B"), then an absent value passes, "" fails with "A", "abcd" fails with "B" and "abc" passes.

Validator focus
- AC-7 Leaving a changed field (BR-6, BR-12), each check starting from "":
  - a) When focus enters and leaves, then it is undetermined.
  - b) When focus enters, the input becomes "1" and focus leaves, then it is invalid with "Błąd".
  - c) When focus enters, the input becomes "1" and then "", and focus leaves, then it is invalid.
  - d) When the input becomes "1" while the field doesn't have focus, and focus then enters and leaves, then it is undetermined; likewise when focus enters, the rule becomes 4 to 10 characters and focus leaves.
  - e) When focus enters, the input becomes "12" and focus leaves, then it is invalid; when focus enters and leaves again without an input, it stays invalid; when focus enters, the input becomes "123" and focus leaves, it is valid.
  - f) When focus enters, it takes the input "" again, equal to the last, and focus leaves, then it is invalid.
  - g) When focus enters, the input becomes "12", its validation is forced and the input becomes "1", then it stays invalid; when it becomes "123", it is valid.

API and build
- AC-8 (code review) Given `ValidationResult`, `ValidationRule` and `Validator`, then they have the public shape in Data — `ValidationResult` is `Equatable` and `Sendable`, with `isValid` and `reason`, `ValidationRule` is `Sendable` for every input, `Validator` is `Sendable` where its input is and starts without focus — and neither `reason(for:)`, `force()` nor a validator takes a `Locale` (Data, BR-9, BR-13).
- AC-9 (code review) Given this increment's sources, then they import Foundation only, hold no user-facing copy, String Catalog or resource, and none reads `Locale.current` or `Locale.autoupdatingCurrent` (no rule here takes a locale; BR-9); no package dependency or product is added (BR-9, BR-13, BR-14).
- AC-10 The lint command, the tests command (Polish and English configurations) and the `UtilitiesKit` iOS build command from `UtilitiesKit/CLAUDE.md` › Commands succeed with no warnings, and the tests run UtilitiesKitTests (BR-13, BR-14).
- AC-11 (code review) Given the package's sources, then they follow `CLAUDE.md` › Code style with one type per file, a file named after its type or the type it extends, and no comments (BR-13).
- AC-12 Given a rule built with the initializer whose check fails "" with "A" and passes any other text, then "" fails with "A" and "a" passes (Data, BR-1).
- AC-13 (code review) Given `UtilitiesKit/README.md`, then its status line names the validators; given `UtilitiesKit/CLAUDE.md` › Rules, then validators take an injected locale when a rule is built, defaulting to `.autoupdatingCurrent`, and copy comes from `String(localized:)`, not a locale; given `docs/specs/README.md` and `docs/specs/validation/validation.md`, then the validation/validators row carries the spec's status (BR-15).

## Open questions
- —

## Changelog
- 2026-10-31 Drafted from FinanceTracker's validator implementation: result, rule, focus-aware validator, required and length rules, composition; no `Locale` parameter (Q-1, Q-2) (create-spec)
- 2026-10-31 Review round 1: a rule that needs a locale takes it when built, defaulting to `.autoupdatingCurrent`, and `String(localized:)` makes copy (Goal, US-4, Data, BR-9, BR-15, AC-8, AC-9, AC-13, Q-1); form-side forcing cited (BR-6); untestable force clause dropped (BR-12); initial focus, package wording and `(code review)` markers (Data, BR-14, AC-8, AC-9, AC-11, AC-13); validation feature index added
- 2026-10-31 Revalidation round 2 (same session at the user's request): exact rule factory signatures in Data (AC-8); the result's semantics in BR-1 (AC-1); the locale clause scoped to rules a later spec adds, and AC-9 to this increment's sources (Data, BR-9, AC-9); the feature index added to the owners (Scope, BR-15, AC-13); form-side forcing cited without claiming the placeholder's text (BR-6, Screens); the `UtilitiesKit` iOS scheme named (AC-10); Approved
