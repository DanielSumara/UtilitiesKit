public struct Validator<Input> {
    public private(set) var result: ValidationResult

    public var input: Input {
        didSet {
            decide()
        }
    }

    public var rule: ValidationRule<Input> {
        didSet {
            decide()
        }
    }

    public init(rule: ValidationRule<Input>, input: Input) {
        self.rule = rule
        self.input = input
        result = rule.reason(for: input) == nil ? .valid : .undetermined
    }

    public mutating func force() {
        if let reason = rule.reason(for: input) {
            result = .invalid(reason: reason)
        } else {
            result = .valid
        }
    }

    private mutating func decide() {
        guard let reason = rule.reason(for: input) else {
            result = .valid
            return
        }
        if case .invalid = result {
            result = .invalid(reason: reason)
        } else {
            result = .undetermined
        }
    }
}

extension Validator: Sendable where Input: Sendable {}
