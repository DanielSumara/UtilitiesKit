public protocol Logger: Sendable {
    func log(_ message: String, level: LogLevel, category: String)
}
