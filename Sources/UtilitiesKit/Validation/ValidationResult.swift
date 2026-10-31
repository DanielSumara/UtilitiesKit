public enum ValidationResult: Equatable, Sendable {
    case undetermined
    case valid
    case invalid(reason: String)

    public var isValid: Bool {
        self == .valid
    }

    public var reason: String? {
        guard case .invalid(let reason) = self else {
            return nil
        }
        return reason
    }
}
