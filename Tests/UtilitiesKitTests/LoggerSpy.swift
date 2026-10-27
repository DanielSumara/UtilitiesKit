import Synchronization
import UtilitiesKit

internal final class LoggerSpy: Logger {
    internal struct Call: Equatable, Sendable {
        internal let message: String
        internal let level: LogLevel
        internal let category: String
    }

    private let storage = Mutex<[Call]>([])

    internal var calls: [Call] {
        storage.withLock { $0 }
    }

    internal func log(_ message: String, level: LogLevel, category: String) {
        storage.withLock { $0.append(Call(message: message, level: level, category: category)) }
    }
}
