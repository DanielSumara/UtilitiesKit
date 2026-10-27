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

    @Test(arguments: [LocaleMatch.polish("Przypomnienia"), LocaleMatch.english("Reminders")])
    func `AC-9 locale match as argument`(entry: LocaleMatch<String>) {
        let expected: [TestLanguage: String] = [.polish: "Przypomnienia", .english: "Reminders"]
        #expect(entry.value == expected[entry.language])
    }
}
