struct DollupError: Error, CustomStringConvertible {
    let description: String
    init(description: String) {
        self.description = description
    }
}
extension DollupError: ExpressibleByStringInterpolation {
    init(stringLiteral value: String) {
        self.init(description: value)
    }
}
