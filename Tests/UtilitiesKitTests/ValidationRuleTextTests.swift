import Testing
import UtilitiesKit

internal struct ValidationRuleTextTests {
    @Test func `AC-3a fails empty text and passes whitespace and other text`() {
        let rule = ValidationRule<String>.required(message: "A")

        #expect(rule.reason(for: "") == "A")
        #expect(rule.reason(for: " ") == nil)
        #expect(rule.reason(for: "a") == nil)
        #expect(rule.reason(for: "abc") == nil)
    }

    @Test func `AC-3b required and at most 3 characters each fail with their own message`() {
        let rule = ValidationRule<String>.allOf([
            .required(message: "A"),
            .length(atMost: 3, message: "B")
        ])

        #expect(rule.reason(for: "") == "A")
        #expect(rule.reason(for: "abcd") == "B")
        #expect(rule.reason(for: "abc") == nil)
    }

    @Test func `AC-4a range of 1 to 80 characters`() {
        let rule = ValidationRule<String>.length(1...80, message: "A")

        #expect(rule.reason(for: "") == "A")
        #expect(rule.reason(for: String(repeating: "a", count: 81)) == "A")
        #expect(rule.reason(for: " ") == nil)
        #expect(rule.reason(for: "OC") == nil)
        #expect(rule.reason(for: String(repeating: "a", count: 80)) == nil)
    }

    @Test func `AC-4b at most 500 characters`() {
        let rule = ValidationRule<String>.length(atMost: 500, message: "A")

        #expect(rule.reason(for: "") == nil)
        #expect(rule.reason(for: String(repeating: "a", count: 500)) == nil)
        #expect(rule.reason(for: String(repeating: "a", count: 501)) == "A")
    }

    @Test func `AC-4c counts characters as the user sees them`() {
        let rule = ValidationRule<String>.length(atMost: 1, message: "A")

        #expect(rule.reason(for: "👍🏽") == nil)
        #expect(rule.reason(for: "ł") == nil)
        #expect(rule.reason(for: "é") == nil)
        #expect(rule.reason(for: "e\u{0301}") == nil)
        #expect(rule.reason(for: "ab") == "A")
    }
}
