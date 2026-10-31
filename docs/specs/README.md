# Specs

Spec Driven Development index of this repo. Workflow: skills `create-spec` and `review-spec`.
Layout: `docs/specs/{feature}/{name}.md` (spec id `{feature}/{name}`); answered questions in `docs/specs/{feature}/decisions/{name}.md`, cited by id (`Q-n`).
Status: `Not started` → `Draft` → `Approved` → `Planned` → `Implemented`. No code before `Approved`.
A spec covers one screen or one capability of one feature; behavior spanning two features is one spec per side.

| Feature | Spec | Scope | Status |
|---|---|---|---|
| logging | [logging/logger](logging/logger.md) | Package skeleton, logger contract: four levels, English message, category from the caller | Implemented |
| testing | [testing/test-utilities](testing/test-utilities.md) | TestUtilitiesKit product: language-keyed `match` on the test plan's Polish and English configurations, Difference diffs | Implemented |
| formatting | formatting/month-title | Month and year as a title in a locale | Not started |
| validation | [validation/validation](validation/validation.md) | Validation feature map: rules, validation result and focus-aware validator | — |
| validation | [validation/validators](validation/validators.md) | Validation result, focus-aware validator, text rules (required, length) and composition; locale only when a rule is built | Planned |
