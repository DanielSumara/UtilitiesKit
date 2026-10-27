# Testing pitfalls

- Difference 1.1.0 `diff(_:_:)` returns `[""]`, not `[]`, for a type whose `==` is false but whose fields are equal: filter blank lines before the `Expected:`/`Received:` fallback
- `withKnownIssue` fails when no issue is recorded: a recorder helper that also runs passing cases needs `isIntermittent: true`
- SwiftLint `sorted_imports` puts `import Testing` before `import TestUtilitiesKit`
- Both `match` overloads record the no-language issue at their own call site: compare comments and return values across overloads, lines only when both calls share one explicit `sourceLocation`
- Entries built on one line share a line number: compare whole `SourceLocation` values (with column) to tell them apart
