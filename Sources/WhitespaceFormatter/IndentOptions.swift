public struct IndentOptions {
    /// Number of spaces per indentation level.
    public var spaces: Int
    /// Whether to indent `case` blocks in `switch` expressions.
    public var `switch`: Bool
    /// Whether to indent `#if`/`#else`/`#endif` blocks.
    public var ifConfig: Bool
    /// Whether to hang alignable conditions in condition lists.
    public var hangConditions: Bool
}
