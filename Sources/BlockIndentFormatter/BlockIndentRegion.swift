struct BlockIndentRegion {
    /// UTF-8 byte offset where this region starts.
    let start: Int
    /// Indentation level, in indentation units.
    let indent: Int
    /// Whitespace prefix, if any, to preserve. Important for multiline string literals.
    let prefix: Substring?
    let suffix: Substring?
    let escapable: Bool
}
