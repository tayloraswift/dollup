import SwiftOperators

public struct WhitespaceOptions {
    public var operators: OperatorTable
    public var width: Int

    public var indent: IndentOptions
    public var braces: BraceStyle?
    public var formatColonPadding: Bool
    public var keywordsOnSameLine: Bool
}
extension WhitespaceOptions {
    init() {
        self.init(
            operators: .standardOperators,
            width: 96,
            indent: IndentOptions.init(spaces: 4, switch: false, ifConfig: false, hangConditions: true),
            braces: .egyptian,
            formatColonPadding: true,
            keywordsOnSameLine: true
        )
    }
}
