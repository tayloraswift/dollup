import SwiftOperators

public struct WhitespaceOptions {
    public var operators: OperatorTable
    public var width: Int

    public var indent: IndentOptions
    public var braces: BraceStyle?
    public var formatColonPadding: Bool
    /// Use these options to control how attributes are folded. They have no effect unless
    /// ``foldKeywords`` is also enabled.
    public var foldAttribute: FoldAttributesOptions
    public var foldKeywords: Bool
}
extension WhitespaceOptions {
    init() {
        self.init(
            operators: .standardOperators,
            width: 96,
            indent: IndentOptions.init(
                spaces: 4,
                switch: false,
                ifConfig: false,
                hangConditions: true
            ),
            braces: .egyptian,
            formatColonPadding: true,
            foldAttribute: .init(),
            foldKeywords: false
        )
    }
}
extension WhitespaceOptions {
    @available(*, deprecated, message: "Use 'foldKeywords' or 'foldAttribute' instead")
    public var keywordsOnSameLine: Bool {
        get { self.foldKeywords }
        set { self.foldKeywords = newValue }
    }
}
