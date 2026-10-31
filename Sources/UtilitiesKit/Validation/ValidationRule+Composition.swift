import Foundation

extension ValidationRule {
    public static func allOf(_ rules: [ValidationRule<Input>]) -> ValidationRule<Input> {
        ValidationRule<Input> { input in
            for rule in rules {
                if let reason = rule.reason(for: input) {
                    return reason
                }
            }
            return nil
        }
    }

    public static func ifPresent<Wrapped>(_ rule: ValidationRule<Wrapped>) -> ValidationRule<Wrapped?> {
        ValidationRule<Wrapped?> { input in
            guard let input else {
                return nil
            }
            return rule.reason(for: input)
        }
    }
}
