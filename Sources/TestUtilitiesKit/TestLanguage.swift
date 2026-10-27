import Foundation
import Testing

public enum TestLanguage: CaseIterable, Sendable, CustomTestStringConvertible {
    case polish
    case english

    public var code: String {
        switch self {
        case .polish: "pl"
        case .english: "en"
        }
    }

    public var locale: Locale {
        switch self {
        case .polish: Locale(identifier: "pl_PL")
        case .english: Locale(identifier: "en_GB")
        }
    }

    public var testDescription: String {
        code
    }
}
