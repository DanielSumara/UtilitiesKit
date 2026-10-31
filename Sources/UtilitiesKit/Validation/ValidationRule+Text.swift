import Foundation

extension ValidationRule where Input == String {
    public static func required(message: String) -> ValidationRule<String> {
        ValidationRule<String> { $0.isEmpty ? message : nil }
    }

    public static func length(_ range: ClosedRange<Int>, message: String) -> ValidationRule<String> {
        ValidationRule<String> { range.contains($0.count) ? nil : message }
    }

    public static func length(atMost maximum: Int, message: String) -> ValidationRule<String> {
        ValidationRule<String> { $0.count <= maximum ? nil : message }
    }
}
