# Logger
Status: Not started · Level: capability · Repo: UtilitiesKit · Feature: logging · Depends on: —

Placeholder: `/create-spec logging/logger` drafts it in place.

## Goal
The UtilitiesKit package skeleton and the logger contract that Core modules inject.

## Needed by
- HomeBudgetApps shell/launch: logging a failed bootstrap at error level, English message, category from the caller; App implements the contract with unified logging (BR-10)
- testing/test-utilities: the UtilitiesKit package skeleton (`Package.swift`, iOS 26 and macOS 26, Swift 6) that adds the TestUtilitiesKit product and its test target (BR-1, BR-10)
