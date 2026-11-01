import Foundation

public struct DisplayDateFormatter: Sendable {
    private let locale: Locale
    private let calendar: Calendar
    private let timeZone: TimeZone

    public init(
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        timeZone: TimeZone = .autoupdatingCurrent
    ) {
        self.locale = locale
        self.calendar = calendar
        self.timeZone = timeZone
    }

    public func monthTitle(year: Int, month: Int) -> String? {
        guard (1...12).contains(month), (1...9999).contains(year) else {
            return nil
        }
        var zonedCalendar = calendar
        zonedCalendar.timeZone = timeZone
        zonedCalendar.locale = locale
        guard let date = zonedCalendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = zonedCalendar
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate("yLLLL")
        return capitalizingFirstCharacter(of: formatter.string(from: date))
    }

    private func capitalizingFirstCharacter(of title: String) -> String {
        guard let first = title.first else {
            return title
        }
        return String(first).uppercased(with: locale) + title.dropFirst()
    }
}
