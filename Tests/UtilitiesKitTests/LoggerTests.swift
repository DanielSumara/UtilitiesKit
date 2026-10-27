import Testing
import UtilitiesKit

internal struct LoggerTests {
    @Test func `AC-6`() {
        let spy = LoggerSpy()
        let logger: any Logger = spy
        logger.log("debug message", level: .debug, category: "alpha")
        logger.log("info message", level: .info, category: "beta")
        logger.log("warning message", level: .warning, category: "gamma")
        logger.log("error message", level: .error, category: "delta")
        #expect(spy.calls == [
            LoggerSpy.Call(message: "debug message", level: .debug, category: "alpha"),
            LoggerSpy.Call(message: "info message", level: .info, category: "beta"),
            LoggerSpy.Call(message: "warning message", level: .warning, category: "gamma"),
            LoggerSpy.Call(message: "error message", level: .error, category: "delta")
        ])
    }
}
