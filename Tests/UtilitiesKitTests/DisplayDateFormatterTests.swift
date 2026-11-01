import Foundation
import Testing
import UtilitiesKit

internal struct DisplayDateFormatterTests {
    private let processLocale: Locale = .current

    private func formatter(_ identifier: String, timeZone: TimeZone = .gmt) -> DisplayDateFormatter {
        DisplayDateFormatter(
            locale: Locale(identifier: identifier),
            calendar: Calendar(identifier: .gregorian),
            timeZone: timeZone
        )
    }

    @Test func `AC-5 months and years out of range give nil`() {
        let polish = formatter("pl_PL")
        #expect(polish.monthTitle(year: 2026, month: 0) == nil)
        #expect(polish.monthTitle(year: 2026, month: 13) == nil)
        #expect(polish.monthTitle(year: 0, month: 10) == nil)
        #expect(polish.monthTitle(year: 10000, month: 10) == nil)
    }

    @Test func `AC-13 far time zones keep October 2026`() throws {
        for zoneIdentifier in ["Pacific/Kiritimati", "Pacific/Pago_Pago"] {
            let zone = try #require(TimeZone(identifier: zoneIdentifier))
            #expect(formatter("pl_PL", timeZone: zone).monthTitle(year: 2026, month: 10) == "Październik 2026")
        }
    }

    @Test func `AC-6 no-argument formatter follows the process language`() {
        let title = DisplayDateFormatter().monthTitle(year: 2026, month: 10)
        switch processLocale.language.languageCode?.identifier {
        case "pl":
            #expect(title == "Październik 2026")
        case "en":
            #expect(title == "October 2026")
        default:
            #expect(title?.isEmpty == false)
        }
    }

    @Test func `AC-2 en_GB and en_US give October 2026`() {
        #expect(formatter("en_GB").monthTitle(year: 2026, month: 10) == "October 2026")
        #expect(formatter("en_US").monthTitle(year: 2026, month: 10) == "October 2026")
    }

    @Test func `AC-3 ja_JP puts the year first`() {
        #expect(formatter("ja_JP").monthTitle(year: 2026, month: 10) == "2026年10月")
    }

    @Test func `AC-1 Polish gives Październik 2026`() {
        #expect(formatter("pl_PL").monthTitle(year: 2026, month: 10) == "Październik 2026")
    }

    @Test func `AC-4 Polish standalone nominative months start with a capital`() {
        let polish = formatter("pl_PL")
        #expect(polish.monthTitle(year: 2026, month: 1) == "Styczeń 2026")
        #expect(polish.monthTitle(year: 2026, month: 2) == "Luty 2026")
        #expect(polish.monthTitle(year: 2026, month: 10) == "Październik 2026")
        #expect(polish.monthTitle(year: 2026, month: 12) == "Grudzień 2026")
        for month in 1...12 {
            let title = polish.monthTitle(year: 2026, month: month) ?? ""
            #expect(!title.isEmpty)
            #expect(title.first?.isUppercase == true)
        }
    }
}
