# UtilitiesKit repo

Public Swift package of domain-agnostic utilities for the HomeBudget apps. Workspace rules: `../CLAUDE.md`.

## Rules
- One target `UtilitiesKit`, Foundation only, iOS 26 and macOS 26; no UI, no domain types (money, days and providers live in the apps' DataKit)
- Formatters, parsers and validators take an injected `Locale`; clocks, logging, preferences and image scaling are contracts the apps implement
- Every public API has Swift Testing tests (`Tests/UtilitiesKitTests`)
- Copy in its String Catalog (`utilities.{area}.{element}`), pl and en
- Public API is the product: SemVer tags, `CHANGELOG.md` per release

## Commands
- Lint: `swiftlint lint --strict --quiet`
- Tests: `xcrun swift test --build-system swiftbuild`
- iOS: `xcodebuild -scheme UtilitiesKit -destination 'generic/platform=iOS' build`
