import Foundation
import Testing
import TestUtilitiesKit

internal struct TestLanguageTests {
    @Test func `AC-9`() {
        #expect(TestLanguage.allCases == [.polish, .english])
        #expect(TestLanguage.allCases.map(\.code) == ["pl", "en"])
        #expect(TestLanguage.allCases.map(\.locale) == [Locale(identifier: "pl_PL"), Locale(identifier: "en_GB")])
        #expect(TestLanguage.allCases.map(\.testDescription) == ["pl", "en"])
    }

    @Test(arguments: [LanguageMatch.polish("Przypomnienia"), LanguageMatch.english("Reminders")])
    func `AC-9 language match as argument`(entry: LanguageMatch<String>) {
        let expected: [TestLanguage: String] = [.polish: "Przypomnienia", .english: "Reminders"]
        #expect(entry.value == expected[entry.language])
    }

    @Test func `AC-16 default locale`() {
        let locale = Locale.current
        let code = locale.language.languageCode?.identifier ?? "—"
        let region = locale.region?.identifier ?? "—"
        #expect(
            "\(code)_\(region)".match(
                .polish(TestLanguage.polish.locale.identifier),
                .english(TestLanguage.english.locale.identifier)
            )
        )
    }
}
