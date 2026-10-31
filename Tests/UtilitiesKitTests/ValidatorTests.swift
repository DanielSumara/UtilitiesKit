import Testing
import UtilitiesKit

internal struct ValidatorTests {
    private let threeToTen = ValidationRule<String>.length(3...10, message: "Błąd")

    @Test func `AC-2a an input becomes valid at once and an invalid one stays undetermined until forced`() {
        var validator = Validator(rule: threeToTen, input: "")
        #expect(validator.result == .undetermined)

        validator.input = "1"
        #expect(validator.result == .undetermined)
        validator.input = "12"
        #expect(validator.result == .undetermined)
        validator.input = "123"
        #expect(validator.result == .valid)

        var forced = Validator(rule: threeToTen, input: "")
        forced.force()
        #expect(forced.result == .invalid(reason: "Błąd"))
    }

    @Test func `AC-2b a valid field becomes undetermined on an invalid input`() {
        var validator = Validator(rule: threeToTen, input: "123")
        #expect(validator.result == .valid)

        validator.input = "12"
        #expect(validator.result == .undetermined)
    }

    @Test func `AC-2c a forced invalid field stays invalid until its input is valid`() {
        var validator = Validator(rule: threeToTen, input: "12")
        validator.force()
        #expect(validator.result == .invalid(reason: "Błąd"))

        validator.input = "1"
        #expect(validator.result == .invalid(reason: "Błąd"))
        validator.input = "123"
        #expect(validator.result == .valid)
        validator.input = "12"
        #expect(validator.result == .undetermined)
    }

    @Test func `AC-2d a field starting valid stays valid when forced and becomes undetermined on an invalid input`() {
        var validator = Validator(rule: threeToTen, input: "123")
        #expect(validator.result == .valid)

        validator.force()
        #expect(validator.result == .valid)
        validator.input = "12"
        #expect(validator.result == .undetermined)
    }

    @Test func `AC-2e an invalid field follows the reason of the failing rule`() {
        let rule = ValidationRule<String>.allOf([
            .length(3...10, message: "A"),
            .length(atMost: 5, message: "B")
        ])
        var validator = Validator(rule: rule, input: "12")
        validator.force()
        #expect(validator.result == .invalid(reason: "A"))

        validator.input = "123456"
        #expect(validator.result == .invalid(reason: "B"))
    }

    @Test func `AC-2f a new rule decides the input again`() {
        var invalid = Validator(rule: threeToTen, input: "12")
        invalid.force()
        invalid.rule = .length(2...10, message: "Błąd")
        #expect(invalid.result == .valid)
        invalid.rule = threeToTen
        #expect(invalid.result == .undetermined)

        var valid = Validator(rule: .length(2...10, message: "Błąd"), input: "12")
        #expect(valid.result == .valid)
        valid.rule = threeToTen
        #expect(valid.result == .undetermined)

        var reasoned = Validator(rule: .length(3...10, message: "A"), input: "1")
        reasoned.force()
        reasoned.rule = .length(4...10, message: "B")
        #expect(reasoned.result == .invalid(reason: "B"))
    }

    @Test func `AC-2g an absent optional is valid and a present invalid one waits for force`() {
        var validator = Validator<String?>(rule: .ifPresent(threeToTen), input: nil)
        #expect(validator.result == .valid)

        validator.input = "12"
        #expect(validator.result == .undetermined)
        validator.force()
        #expect(validator.result == .invalid(reason: "Błąd"))
    }

    @Test func `AC-7a focus entering and leaving without an input is undetermined`() {
        var validator = Validator(rule: threeToTen, input: "")
        validator.hasFocus = true
        validator.hasFocus = false
        #expect(validator.result == .undetermined)
    }

    @Test func `AC-7b leaving a field after an input forces validation`() {
        var validator = Validator(rule: threeToTen, input: "")
        validator.hasFocus = true
        validator.input = "1"
        validator.hasFocus = false
        #expect(validator.result == .invalid(reason: "Błąd"))
    }

    @Test func `AC-7c an input undone before leaving still forces validation`() {
        var validator = Validator(rule: threeToTen, input: "")
        validator.hasFocus = true
        validator.input = "1"
        validator.input = ""
        validator.hasFocus = false
        #expect(validator.result == .invalid(reason: "Błąd"))
    }

    @Test func `AC-7d an input without focus and a new rule do not count`() {
        var unfocused = Validator(rule: threeToTen, input: "")
        unfocused.input = "1"
        unfocused.hasFocus = true
        unfocused.hasFocus = false
        #expect(unfocused.result == .undetermined)

        var reruled = Validator(rule: threeToTen, input: "")
        reruled.hasFocus = true
        reruled.rule = .length(4...10, message: "Błąd")
        reruled.hasFocus = false
        #expect(reruled.result == .undetermined)
    }

    @Test func `AC-7e leaving without an input keeps the result and a valid input becomes valid`() {
        var validator = Validator(rule: threeToTen, input: "")
        validator.hasFocus = true
        validator.input = "12"
        validator.hasFocus = false
        #expect(validator.result == .invalid(reason: "Błąd"))

        validator.hasFocus = true
        validator.hasFocus = false
        #expect(validator.result == .invalid(reason: "Błąd"))

        validator.hasFocus = true
        validator.input = "123"
        validator.hasFocus = false
        #expect(validator.result == .valid)
    }

    @Test func `AC-7f an input equal to the last one forces validation on leaving`() {
        var validator = Validator(rule: threeToTen, input: "")
        validator.hasFocus = true
        validator.input = ""
        validator.hasFocus = false
        #expect(validator.result == .invalid(reason: "Błąd"))
    }

    @Test func `AC-7g a forced invalid field stays invalid while focused until its input is valid`() {
        var validator = Validator(rule: threeToTen, input: "")
        validator.hasFocus = true
        validator.input = "12"
        validator.force()
        validator.input = "1"
        #expect(validator.result == .invalid(reason: "Błąd"))

        validator.input = "123"
        #expect(validator.result == .valid)
    }
}
