struct BlockIndentRegion {
    /// UTF-8 byte offset where this region starts.
    let start: Int
    /// Indentation level, in indentation units.
    let indent: Int
}
