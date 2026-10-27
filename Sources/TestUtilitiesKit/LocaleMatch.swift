import Testing

public struct LocaleMatch<Value: Equatable> {
    public let language: TestLanguage
    public let value: Value
    public let sourceLocation: SourceLocation

    public init(language: TestLanguage, value: Value, sourceLocation: SourceLocation) {
        self.language = language
        self.value = value
        self.sourceLocation = sourceLocation
    }

    public static func polish(_ value: Value, sourceLocation: SourceLocation = #_sourceLocation) -> LocaleMatch<Value> {
        LocaleMatch(language: .polish, value: value, sourceLocation: sourceLocation)
    }

    public static func english(_ value: Value, sourceLocation: SourceLocation = #_sourceLocation) -> LocaleMatch<Value> {
        LocaleMatch(language: .english, value: value, sourceLocation: sourceLocation)
    }
}

extension LocaleMatch: Sendable where Value: Sendable {}
