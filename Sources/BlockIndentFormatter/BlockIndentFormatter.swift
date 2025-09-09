import SwiftSyntax
import SwiftParser

/// This pass detects Google-style “code rectangles”, and reformats Swift code to fit within a
/// specified maximum line length.
public struct BlockIndentFormatter {
    public static func correct(_ content: String, length: Int) -> String {
        var current: String = content
        while true {
            let sourceTree = Parser.parse(source: current)
            let visitor: BlockIndentVisitor = .init(length: length, source: current)
            visitor.walk(sourceTree)

            if visitor.edits.isEmpty {
                // Post-processing step: Clean up any trailing whitespace on each line.
                let lines: [Substring] = current.split(
                    separator: "\n",
                    omittingEmptySubsequences: false
                )
                return lines.map { $0.trimmingWhitespaceFromEnd() }.joined(separator: "\n")
            }

            // Apply the edits in reverse order to avoid location shifts
            for edit: Edit in visitor.edits.reversed() {
                let start: String.Index = current.utf8.index(current.utf8.startIndex, offsetBy: edit.start.utf8Offset)
                let end: String.Index = current.utf8.index(start, offsetBy: edit.length)
                current.replaceSubrange(start..<end, with: edit.newText)
            }
        }
    }
}
