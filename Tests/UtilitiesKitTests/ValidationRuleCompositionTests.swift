import Testing
import UtilitiesKit

internal struct ValidationRuleCompositionTests {
    @Test func `AC-5a allOf fails with the reason of the first failing rule`() {
        let rule = ValidationRule<String>.allOf([
            .length(3...5, message: "A"),
            .length(atMost: 4, message: "B")
        ])

        #expect(rule.reason(for: "abcde") == "B")
        #expect(rule.reason(for: "abcdef") == "A")
    }

    @Test func `AC-5b allOf passes when every rule passes`() {
        let rule = ValidationRule<String>.allOf([
            .length(3...5, message: "A"),
            .length(atMost: 4, message: "B")
        ])

        #expect(rule.reason(for: "abcd") == nil)
    }

    @Test func `AC-6a ifPresent passes an absent value and applies its rule to a present one`() {
        let rule = ValidationRule<String>.ifPresent(.required(message: "A"))

        #expect(rule.reason(for: nil) == nil)
        #expect(rule.reason(for: "") == "A")
        #expect(rule.reason(for: "abc") == nil)
    }

    @Test func `AC-6b ifPresent of allOf passes absent and gives the first failing reason`() {
        let rule = ValidationRule<String>.ifPresent(
            .allOf([
                .required(message: "A"),
                .length(atMost: 3, message: "B")
            ])
        )

        #expect(rule.reason(for: nil) == nil)
        #expect(rule.reason(for: "") == "A")
        #expect(rule.reason(for: "abcd") == "B")
        #expect(rule.reason(for: "abc") == nil)
    }
}
