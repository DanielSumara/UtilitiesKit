import Testing
import UtilitiesKit

internal struct ValidationRuleTests {
    @Test func `AC-12 fails the empty text with its message and passes other text`() {
        let rule = ValidationRule<String> { $0.isEmpty ? "A" : nil }

        #expect(rule.reason(for: "") == "A")
        #expect(rule.reason(for: "a") == nil)
    }
}
