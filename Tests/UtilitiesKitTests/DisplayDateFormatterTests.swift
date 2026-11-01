import Foundation
import Testing
import UtilitiesKit

internal struct DisplayDateFormatterTests {
    private func formatter(_ identifier: String) -> DisplayDateFormatter {
        DisplayDateFormatter(
            locale: Locale(identifier: identifier),
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(identifier: "UTC") ?? .gmt
        )
    }

    @Test func `AC-2 en_GB and en_US give October 2026`() {
        #expect(formatter("en_GB").monthTitle(year: 2026, month: 10) == "October 2026")
        #expect(formatter("en_US").monthTitle(year: 2026, month: 10) == "October 2026")
    }

    @Test func `AC-3 ja_JP puts the year first`() {
        #expect(formatter("ja_JP").monthTitle(year: 2026, month: 10) == "2026年10月")
    }
}
