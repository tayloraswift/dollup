struct Line {
    /// UTF-8 byte offsets where non-whitespace characters appear.
    let range: Range<Int>
    /// The content of the line, with all leading whitespace and trailing whitespace removed.
    /// Must not be empty!
    let text: Substring
}
