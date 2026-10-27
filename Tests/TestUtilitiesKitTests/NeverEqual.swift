internal struct NeverEqual: Equatable {
    let text: String

    static func == (lhs: NeverEqual, rhs: NeverEqual) -> Bool {
        false
    }
}
