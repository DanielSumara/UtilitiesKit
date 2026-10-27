# Decisions: logging/logger

- Q-1 Which levels does the contract expose now? → All four: `log(_:level:category:)` over debug, info, warning and error, declared from least to most severe. Only errors are logged today, but one public API is cheaper than adding levels to a released contract later. Shapes: Data, BR-3, BR-4. (create-spec, 2026-10-27)
- Q-2 What does a log call carry as the failure? → The English message `String`, built by the caller; the contract takes no `Error`, so UtilitiesKit holds no error type, reflection or formatting. Shapes: Data, BR-5. (create-spec, 2026-10-27)
- Q-3 How does the caller pass the category? → A plain `String`: a short lowercase area name such as `launch`, stable across releases. No `LogCategory` newtype or validation, which no caller needs. Shapes: BR-6. (create-spec, 2026-10-27)
- Q-4 Who owns the privacy of the logged text? → shell/launch, with the App's unified-logging implementation; the contract neither requires public nor private text and stays out of it. Shapes: Scope Out, BR-7. (create-spec, 2026-10-27)
