# Test utilities — implementation plan
Spec: UtilitiesKit/docs/specs/testing/test-utilities.md
Repo: UtilitiesKit
Status: Ready
Run base: —
Depends on: —

Delta plan: TestUtilitiesKit exists from an earlier version (`TestLanguage`, `LocaleMatch`, `Equatable+LocaleMatch`, tests in `TestUtilitiesKitTests`). Slices change it to the current spec; the existing tests are the baseline.

## Slices
### S1 — Workspace: readable committed scheme under the settings
- ACs: —
- Area: HomeBudgetApps/.claude/settings.json (linked at the workspace root; HomeBudgetApps repo, own commit)
- Depends on: —
- Skills: —
- Review: diff-only
- Builds: deny rules that leave `.swiftpm/xcode/xcshareddata/xcschemes/` readable; S4 reads and commits the scheme
- Done when: `Read(**/.swiftpm/**)` replaced by denies covering every other `.swiftpm/` path (list the folder first; Claude Code deny rules have no negation); a file under `.swiftpm/xcode/xcshareddata/xcschemes/` is readable, the rest of `.swiftpm/` is not (checked after a session restart)
- Manual ACs: —

### S2 — TestUtilitiesKit: rename LocaleMatch to LanguageMatch
- ACs: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-8, AC-9, AC-13
- Area: UtilitiesKit/Sources/TestUtilitiesKit, UtilitiesKit/Tests/TestUtilitiesKitTests
- Depends on: —
- Skills: —
- Review: diff-only
- Builds: `LanguageMatch<Value>` (`LanguageMatch.swift`), `Equatable+LanguageMatch.swift` (git mv, one type per file), tests and helpers using the new name; behavior unchanged, explicit locale still required
- Done when: existing tests citing AC-1–AC-6, AC-8, AC-9, AC-13 pass under `xcrun swift test --build-system swiftbuild`; no `LocaleMatch` left in sources, tests or file names; lint clean; TestUtilitiesKit builds for iOS and macOS
- Manual ACs: —

### S3 — TestUtilitiesKit: `match` locale defaults to `.current`
- ACs: AC-10
- Area: UtilitiesKit/Sources/TestUtilitiesKit
- Depends on: S2
- Skills: —
- Review: full
- Builds: both `match` overloads with `in locale: Locale = .current` (`Equatable+LanguageMatch.swift`); `.current` the only process state read, no `autoupdatingCurrent`, `preferredLanguages`, `Bundle` access
- Done when: AC-1–AC-6, AC-8, AC-13 tests still pass; call sites without a locale compile; lint clean; iOS and macOS builds clean without warnings
- Manual ACs: —

### S4 — Package: test plan, committed scheme, gitignore, default-locale self-test
- ACs: AC-11, AC-15, AC-16
- Area: UtilitiesKit/UtilitiesKit.xctestplan, UtilitiesKit/.swiftpm/xcode/xcshareddata/xcschemes/UtilitiesKit-Package.xcscheme, UtilitiesKit/.gitignore, UtilitiesKit/Tests/TestUtilitiesKitTests
- Depends on: S1, S3
- Skills: —
- Review: full
- Builds: `UtilitiesKit.xctestplan` (configurations Polish `pl`/PL and English `en`/GB; UtilitiesKitTests and TestUtilitiesKitTests; default plan of the scheme); shared scheme `UtilitiesKit-Package`; `.gitignore` re-including `.swiftpm/`, `.swiftpm/xcode/`, `.swiftpm/xcode/xcshareddata/`, `.swiftpm/xcode/xcshareddata/xcschemes/` (each level, the rest ignored); a default-locale test (name cites AC-16) in `TestUtilitiesKitTests`
- Done when: `git check-ignore` reports the scheme not ignored and the rest of `.swiftpm/` ignored; `xcodebuild -scheme UtilitiesKit-Package -testPlan UtilitiesKit -destination 'platform=macOS' test` passes in both configurations, AC-16 test included; lint clean; iOS build of TestUtilitiesKit clean without warnings
- Manual ACs: AC-15

### S5 — Owners: CLAUDE.md files, SwiftLint, review ACs
- ACs: AC-12
- Area: UtilitiesKit/CLAUDE.md, CLAUDE.md (workspace root, HomeBudgetApps repo), UtilitiesKit/.swiftlint.yml
- Depends on: S1, S4
- Skills: —
- Review: diff-only
- Builds: —
- Done when: `UtilitiesKit/CLAUDE.md` › Rules (second product, imports, Difference, tests in both language configurations) and › Commands (tests via the test plan replacing `swift test`; iOS build of TestUtilitiesKit); root `CLAUDE.md` › Structure, › Allowed imports, › Commands (UtilitiesKit tests through its test plan); `.swiftlint.yml` rules `utilitieskit_imports` / `testutilitieskit_imports` as BR-12 says; sources hold a single `return true` with one `// Workaround:` line; the scheme is readable under the workspace settings
- Manual ACs: —

## AC coverage
| AC | Slice | Verified by |
|---|---|---|
| AC-1 | S2 | test `AC-1` |
| AC-2 | S2 | test `AC-2` |
| AC-3 | S2 | test `AC-3` |
| AC-4 | S2 | test `AC-4` |
| AC-5 | S2 | test `AC-5` |
| AC-6 | S2 | test `AC-6` |
| AC-8 | S2 | test `AC-8` |
| AC-9 | S2 | test `AC-9` |
| AC-10 | S3 | review (grep for forbidden APIs, Package.swift pin) |
| AC-11 | S4 | lint, test-plan command and iOS build, no warnings |
| AC-12 | S5 | review (owners, `git check-ignore`, scheme readable) |
| AC-13 | S2 | test `AC-13` |
| AC-15 | S4 | manual: result bundle |
| AC-16 | S4 | test `AC-16` in both configurations |

## Manual verification
- AC-15 — run the S4 test-plan command; open the `.xcresult` (`xcrun xcresulttool get test-results tests --path <bundle>`) and check the configurations Polish and English each list every test

## Out of scope
- Linking TestUtilitiesKit to the apps' test targets and the apps' test plans: HomeBudgetApps shell/test-languages
- Domain fixtures and doubles: HomeBudgetApps TestKit

## Progress
| Slice | Status | Base | Head | Review |
|---|---|---|---|---|
| S1 | Pending | — | — | — |
| S2 | Pending | — | — | — |
| S3 | Pending | — | — | — |
| S4 | Pending | — | — | — |
| S5 | Pending | — | — | — |

## Open questions
- S1: the deny syntax has no negation, so the implementer enumerates the other `.swiftpm/` subfolders; a new folder SwiftPM adds later stays readable until listed
- S1 and S5 touch the HomeBudgetApps repo (settings, root `CLAUDE.md`): separate commit there
