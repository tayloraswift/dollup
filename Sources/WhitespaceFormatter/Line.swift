struct Line {
    /// UTF-8 byte offsets where non-whitespace characters appear.
    let range: Range<Int>
    /// The number of characters between the last newline and the first non-whitespace
    /// character on this line, or `nil` if the line is empty or contains only whitespace.
    let column: Int?
    /// The content of the line, with all leading whitespace and trailing whitespace removed.
    /// Must not be empty!
    let text: Substring
}
