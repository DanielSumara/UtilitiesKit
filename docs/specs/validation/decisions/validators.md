# Decisions: validation/validators

- Q-1 Which locale does a validator or rule use? → None takes a `Locale`: this increment's rules are locale-neutral and a form gives each rule its message. A later rule that needs a locale reads the OS locale (`Locale.autoupdatingCurrent`) internally, or omits locale handling, never a parameter. Shapes: Scope › Out, Data, BR-9, BR-15, AC-8, AC-9. (create-spec, 2026-10-31)
- Q-2 Which FinanceTracker rules does this increment cover? → The core (`ValidationResult`, `ValidationRule`, `Validator` with focus), text rules (`required`, `length` range and at most) and composition (`allOf`, `ifPresent`). Comparisons, `parsed`, decimal places, amount, rate and account number arrive with the first spec that needs each. Shapes: Scope, Data. (create-spec, 2026-10-31)
