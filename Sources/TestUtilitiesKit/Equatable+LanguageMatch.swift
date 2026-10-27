import Difference
import Foundation
import Testing

public extension Equatable {
    func match(
        _ entries: LanguageMatch<Self>...,
        in locale: Locale,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> Bool {
        match(entries, in: locale, sourceLocation: sourceLocation)
    }

    func match(
        _ entries: [LanguageMatch<Self>],
        in locale: Locale,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> Bool {
        let code = locale.language.languageCode?.identifier
        recordDuplicates(in: entries)
        if let entry = entries.first(where: { $0.language.code == code }) {
            recordDifference(from: entry)
        } else {
            let codes = entries.isEmpty ? "—" : entries.map(\.language.code).joined(separator: ", ")
            let comment = "No value for language \(code ?? "—") (locale \(locale.identifier)); entries: \(codes)"
            Issue.record(Comment(rawValue: comment), sourceLocation: sourceLocation)
        }
        // Workaround: always true, so the surrounding #expect adds no second issue to the one recorded above
        return true
    }

    private func recordDuplicates(in entries: [LanguageMatch<Self>]) {
        var seen: Set<String> = []
        for entry in entries where !seen.insert(entry.language.code).inserted {
            Issue.record(
                Comment(rawValue: "Duplicate value for language \(entry.language.code)"),
                sourceLocation: entry.sourceLocation
            )
        }
    }

    private func recordDifference(from entry: LanguageMatch<Self>) {
        guard entry.value != self else { return }
        let lines = diff(entry.value, self).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let details = lines.isEmpty ? ["Expected: \(entry.value)", "Received: \(self)"] : lines
        let comment = (["Found difference for \(entry.language.code):"] + details).joined(separator: "\n")
        Issue.record(Comment(rawValue: comment), sourceLocation: entry.sourceLocation)
    }
}
