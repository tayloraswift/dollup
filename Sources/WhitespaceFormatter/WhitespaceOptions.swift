import SwiftOperators

public struct WhitespaceOptions {
    public var operators: OperatorTable
    public var width: Int

    public var indent: IndentOptions
    public var braces: BraceStyle?
    public var spacesAfterColons: Bool
    public var keywordsOnSameLine: Bool
}
extension WhitespaceOptions {
    init() {
        self.init(
            operators: .standardOperators,
            width: 96,
            indent: IndentOptions.init(spaces: 4, ifConfig: false),
            braces: .egyptian,
            spacesAfterColons: true,
            keywordsOnSameLine: true
        )
    }
}
