import WhitespaceFormatter

public struct DollupSettings: ~Copyable {
    public var check: Bool

    private(set) var whitespace: WhitespaceFormatter

    init() {
        self.check = true
        self.whitespace = .init { _ in }
    }
}
extension DollupSettings {
    public mutating func whitespace(
        _ configure: (inout WhitespaceOptions) throws -> ()
    ) rethrows {
        self.whitespace = try .init(configure: configure)
    }
}
