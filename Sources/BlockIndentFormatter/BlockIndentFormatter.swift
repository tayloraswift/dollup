/// This pass detects Google-style “code rectangles”, and reformats Swift code to fit within a
/// specified maximum line length.
public struct BlockIndentFormatter {
    public static func correct(_ content: String, length: Int) -> String {
        // We perform the rewrite iteratively until no more changes are made.
        // This handles cases where formatting a line creates a new, nested line
        // that also needs to be formatted.
        var current: String = content
        while true {
            let rewriter: BlockIndentRewriter = .init(
                length: length,
                source: current
            )
            // Post-processing step: Clean up any trailing whitespace on each line.
            let lines: [Substring] = "\(rewriter.format())".split(
                separator: "\n",
                omittingEmptySubsequences: false
            )
            let formatted: String = lines.map { $0.trimmingWhitespaceFromEnd() }.joined(separator: "\n")

            if  formatted != current {
                current = formatted
            } else {
                return formatted
            }
        }
    }
}
