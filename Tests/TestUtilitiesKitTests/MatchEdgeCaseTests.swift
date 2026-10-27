import Foundation
import Synchronization
import Testing
import TestUtilitiesKit

internal struct MatchEdgeCaseTests {
    private struct Outcome: Equatable {
        let returned: Bool
        let comments: [String]
        let lines: [Int?]
    }

    private func comments(of recorded: [Issue]) -> [String] {
        recorded.map { $0.comments.first?.rawValue ?? "" }
    }

    private func outcome(_ body: () -> Bool) -> Outcome {
        let returned = Mutex(false)
        let recorded = IssueRecorder.issues(isIntermittent: true) { returned.withLock { $0 = body() } }
        return Outcome(
            returned: returned.withLock { $0 },
            comments: comments(of: recorded),
            lines: recorded.map { $0.sourceLocation?.line }
        )
    }

    @Test func `AC-5`() {
        let entries: [LocaleMatch<String>] = [.polish("Przypomnienia"), .english("Reminders")]
        let germanLine = #line + 1
        let german = outcome { "x".match(entries, in: Locale(identifier: "de_DE")) }
        #expect(german.returned)
        #expect(german.comments == ["No value for language de (locale de_DE); entries: pl, en"])
        #expect(german.lines == [germanLine])

        let emptyLine = #line + 1
        let empty = outcome { "x".match(entries, in: Locale(identifier: "")) }
        #expect(empty.returned)
        #expect(empty.comments == ["No value for language — (locale ); entries: pl, en"])
        #expect(empty.lines == [emptyLine])

        let noneLine = #line + 1
        let none = outcome { "x".match([LocaleMatch<String>](), in: Locale(identifier: "pl_PL")) }
        #expect(none.returned)
        #expect(none.comments == ["No value for language pl (locale pl_PL); entries: —"])
        #expect(none.lines == [noneLine])
    }

    @Test func `AC-6 two polish entries`() {
        let first = LocaleMatch.polish("A")
        let second = LocaleMatch.polish("B")
        let recorded = IssueRecorder.issues(isIntermittent: true) { _ = "A".match([first, second], in: Locale(identifier: "pl_PL")) }
        #expect(comments(of: recorded) == ["Duplicate value for language pl"])
        #expect(recorded.first?.sourceLocation == second.sourceLocation)
    }

    @Test func `AC-6 three polish entries`() {
        let entries: [LocaleMatch<String>] = [.polish("A"), .polish("B"), .polish("C")]
        let recorded = IssueRecorder.issues(isIntermittent: true) { _ = "A".match(entries, in: Locale(identifier: "pl_PL")) }
        #expect(comments(of: recorded) == Array(repeating: "Duplicate value for language pl", count: 2))
        #expect(recorded.map(\.sourceLocation) == [entries[1].sourceLocation, entries[2].sourceLocation])
    }

    @Test func `AC-6 duplicate english in polish locale`() {
        let entries: [LocaleMatch<String>] = [.english("A"), .polish("P"), .english("B")]
        let recorded = IssueRecorder.issues(isIntermittent: true) { _ = "P".match(entries, in: Locale(identifier: "pl_PL")) }
        #expect(comments(of: recorded) == ["Duplicate value for language en"])
        #expect(recorded.first?.sourceLocation == entries[2].sourceLocation)
    }

    @Test func `AC-8 AC-1 equal values`() {
        let entries: [LocaleMatch<String>] = [.polish("Przypomnienia"), .english("Reminders")]
        let array = outcome { "Reminders".match(entries, in: Locale(identifier: "en_GB")) }
        let variadic = outcome { "Reminders".match(.polish("Przypomnienia"), .english("Reminders"), in: Locale(identifier: "en_GB")) }
        #expect(array == Outcome(returned: true, comments: [], lines: []))
        #expect(variadic == array)
    }

    @Test func `AC-8 AC-3 difference`() {
        let entry = LocaleMatch.polish(Title(text: "A", count: 1))
        let value = Title(text: "A", count: 2)
        let array = outcome { value.match([entry], in: Locale(identifier: "pl_PL")) }
        let variadic = outcome { value.match(entry, in: Locale(identifier: "pl_PL")) }
        #expect(array.returned)
        #expect(array.comments.count == 1)
        #expect(array.lines == [entry.sourceLocation.line])
        #expect(variadic == array)
    }

    @Test func `AC-8 AC-3 fallback`() {
        let entry = LocaleMatch.polish(NeverEqual(text: "A"))
        let value = NeverEqual(text: "A")
        let array = outcome { value.match([entry], in: Locale(identifier: "pl_PL")) }
        let variadic = outcome { value.match(entry, in: Locale(identifier: "pl_PL")) }
        #expect(array.returned)
        #expect(array.comments.count == 1)
        #expect(array.lines == [entry.sourceLocation.line])
        #expect(variadic == array)
    }

    @Test func `AC-8 AC-5 no language`() {
        let entries: [LocaleMatch<String>] = [.polish("Przypomnienia"), .english("Reminders")]
        let location = #_sourceLocation
        for identifier in ["de_DE", ""] {
            let locale = Locale(identifier: identifier)
            let array = outcome { "x".match(entries, in: locale, sourceLocation: location) }
            let variadic = outcome { "x".match(.polish("Przypomnienia"), .english("Reminders"), in: locale, sourceLocation: location) }
            #expect(array.comments.count == 1)
            #expect(array.lines == [location.line])
            #expect(variadic == array)
        }
        let array = outcome { "x".match([LocaleMatch<String>](), in: Locale(identifier: "pl_PL"), sourceLocation: location) }
        let variadic = outcome { "x".match(in: Locale(identifier: "pl_PL"), sourceLocation: location) }
        #expect(array.lines == [location.line])
        #expect(variadic == array)
    }
}
