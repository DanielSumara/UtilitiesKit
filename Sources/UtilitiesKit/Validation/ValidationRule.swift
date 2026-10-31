public struct ValidationRule<Input>: Sendable {
    private let check: @Sendable (Input) -> String?

    public init(_ check: @escaping @Sendable (Input) -> String?) {
        self.check = check
    }

    public func reason(for input: Input) -> String? {
        check(input)
    }
}
