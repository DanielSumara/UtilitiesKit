import Synchronization
import Testing

internal enum IssueRecorder {
    static func issues(isIntermittent: Bool = false, in body: () -> Void) -> [Issue] {
        let recorded = Mutex<[Issue]>([])
        withKnownIssue(isIntermittent: isIntermittent) {
            body()
        } matching: { issue in
            recorded.withLock { $0.append(issue) }
            return true
        }
        return recorded.withLock { $0 }
    }
}
