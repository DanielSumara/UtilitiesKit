import Foundation
import Testing
import TestUtilitiesKit

internal struct MatchTests {
    @Test func `AC-1`() {
        #expect("Przypomnienia".match(.polish("Przypomnienia"), .english("Reminders"), in: Locale(identifier: "pl_PL")))
        #expect("Reminders".match(.polish("Przypomnienia"), .english("Reminders"), in: Locale(identifier: "en_GB")))
        #expect("Reminders".match([.polish("Przypomnienia"), .english("Reminders")], in: Locale(identifier: "en_GB")))
    }

    @Test(arguments: ["pl", "pl_DE"])
    func `AC-2 polish`(identifier: String) {
        let locale = Locale(identifier: identifier)
        let entries: [LocaleMatch<String>] = [.polish("Przypomnienia"), .english("Reminders")]
        #expect("Przypomnienia".match(entries, in: locale))
        let recorded = IssueRecorder.issues { _ = "Reminders".match(entries, in: locale) }
        #expect(recorded.count == 1)
        #expect(recorded.first?.sourceLocation?.line == entries[0].sourceLocation.line)
        #expect(recorded.first?.comments.first?.rawValue.hasPrefix("Found difference for pl:") == true)
    }

    @Test(arguments: ["en", "en_US"])
    func `AC-2 english`(identifier: String) {
        let locale = Locale(identifier: identifier)
        let entries: [LocaleMatch<String>] = [.polish("Przypomnienia"), .english("Reminders")]
        #expect("Reminders".match(entries, in: locale))
        let recorded = IssueRecorder.issues { _ = "Przypomnienia".match(entries, in: locale) }
        #expect(recorded.count == 1)
        #expect(recorded.first?.sourceLocation?.line == entries[1].sourceLocation.line)
        #expect(recorded.first?.comments.first?.rawValue.hasPrefix("Found difference for en:") == true)
    }

    @Test func `AC-3`() {
        let entry = LocaleMatch.polish(Title(text: "A", count: 1))
        let recorded = IssueRecorder.issues {
            let result = Title(text: "A", count: 2).match(entry, in: Locale(identifier: "pl_PL"))
            #expect(result)
        }
        #expect(recorded.count == 1)
        #expect(recorded.first?.sourceLocation?.line == entry.sourceLocation.line)
        let comment = recorded.first?.comments.first?.rawValue ?? ""
        #expect(comment.hasPrefix("Found difference for pl:"))
        #expect(comment.contains("count"))
    }

    @Test func `AC-3 fallback without difference lines`() {
        let entry = LocaleMatch.polish(NeverEqual(text: "A"))
        let recorded = IssueRecorder.issues {
            let result = NeverEqual(text: "A").match(entry, in: Locale(identifier: "pl_PL"))
            #expect(result)
        }
        #expect(recorded.count == 1)
        #expect(recorded.first?.sourceLocation == entry.sourceLocation)
        let lines = recorded.first?.comments.first?.rawValue.split(separator: "\n").map(String.init) ?? []
        #expect(lines.count == 3)
        #expect(lines.first == "Found difference for pl:")
        #expect(lines.dropFirst().first?.hasPrefix("Expected: ") == true)
        #expect(lines.last?.hasPrefix("Received: ") == true)
    }

    @Test func `AC-4`() {
        let recorded = IssueRecorder.issues {
            #expect("B".match(.polish("A"), in: Locale(identifier: "pl_PL")))
        }
        #expect(recorded.count == 1)
    }

    @Test func `AC-13`() {
        let subject: String? = nil
        #expect(subject.match(.polish(nil), .english("Reminders"), in: Locale(identifier: "pl_PL")))
        let entries: [LocaleMatch<String?>] = [.polish(nil), .english("Reminders")]
        let recorded = IssueRecorder.issues { _ = subject.match(entries, in: Locale(identifier: "en_GB")) }
        #expect(recorded.count == 1)
        #expect(recorded.first?.sourceLocation?.line == entries[1].sourceLocation.line)
    }
}
