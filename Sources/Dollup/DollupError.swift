public struct DollupError: Error, CustomStringConvertible {
    public let description: String
    init(description: String) {
        self.description = description
    }
}
extension DollupError: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.init(description: value)
    }
}
