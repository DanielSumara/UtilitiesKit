import Difference
import Foundation
import Testing

public extension Equatable {
    func match(
        _ entries: LocaleMatch<Self>...,
        in locale: Locale,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> Bool {
        match(entries, in: locale, sourceLocation: sourceLocation)
    }

    func match(
        _ entries: [LocaleMatch<Self>],
        in locale: Locale,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> Bool {
        let code = locale.language.languageCode?.identifier
        if let entry = entries.first(where: { $0.language.code == code }), entry.value != self {
            let lines = diff(entry.value, self).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            let details = lines.isEmpty ? ["Expected: \(entry.value)", "Received: \(self)"] : lines
            let comment = (["Found difference for \(entry.language.code):"] + details).joined(separator: "\n")
            Issue.record(Comment(rawValue: comment), sourceLocation: entry.sourceLocation)
        }
        // Workaround: always true, so the surrounding #expect adds no second issue to the one recorded above
        return true
    }
}
