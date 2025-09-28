struct BlockIndentableLine {
    /// UTF-8 byte offset where the first non-whitespace character appears.
    let start: Int
    /// The content of the line, with all leading whitespace and trailing whitespace removed.
    /// Must not be empty!
    let text: Substring
}
