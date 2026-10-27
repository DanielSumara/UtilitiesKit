import Testing
import UtilitiesKit

internal struct LogLevelTests {
    @Test func `AC-5`() {
        #expect(LogLevel.allCases == [.debug, .info, .warning, .error])
    }
}
