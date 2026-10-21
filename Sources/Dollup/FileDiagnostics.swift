import SystemIO

public struct FileDiagnostics: Sendable, CustomStringConvertible {
    public let file: FilePath
    public let message: String

    public init(file: FilePath, message: String) {
        self.file = file
        self.message = message
    }

    public var description: String {
        """
        error: in '\(self.file)':
        \(self.message)
        """
    }
}
