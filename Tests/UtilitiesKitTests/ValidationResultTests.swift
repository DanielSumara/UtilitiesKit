import Testing
import UtilitiesKit

internal struct ValidationResultTests {
    @Test func `AC-1 valid has no reason`() {
        let result = ValidationResult.valid

        #expect(result.isValid)
        #expect(result.reason == nil)
    }

    @Test func `AC-1 undetermined is not valid and has no reason`() {
        let result = ValidationResult.undetermined

        #expect(!result.isValid)
        #expect(result.reason == nil)
    }

    @Test func `AC-1 invalid carries its reason`() {
        let result = ValidationResult.invalid(reason: "A")

        #expect(!result.isValid)
        #expect(result.reason == "A")
    }
}
