import SwiftSyntax
import SwiftParser

/// This pass detects Google-style “code rectangles”, and reformats Swift code to fit within a
/// specified maximum line length.
public struct BlockIndentFormatter {
    public static func reindent(_ content: String, by indent: Int) -> String {
        let tree: SourceFileSyntax = Parser.parse(source: content)
        let calculator: BlockIndentCalculator = .init()

        calculator.walk(tree)

        let lines: [BlockIndentableLine?] = Self.lines(of: content)
        return Self.indent(lines, in: calculator.regions, by: indent)
    }

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
                let start: String.Index = current.utf8.index(
                    current.utf8.startIndex,
                    offsetBy: edit.start.utf8Offset
                )
                let end: String.Index = current.utf8.index(start, offsetBy: edit.length)
                current.replaceSubrange(start..<end, with: edit.newText)
            }
        }
    }
}
extension BlockIndentFormatter {
    private static func indent(
        _ lines: [BlockIndentableLine?],
        in regions: [BlockIndentRegion],
        by indent: Int
    ) -> String {
        var regions: [BlockIndentRegion].Iterator = regions.makeIterator()

        guard
        var current: BlockIndentRegion = regions.next() else {
            fatalError("regions list is empty!!!")
        }

        var next: BlockIndentRegion? = regions.next()

        return lines.reduce(into: "") {
            if  let line: BlockIndentableLine = $1 {
                while let region: BlockIndentRegion = next, region.start <= line.start {
                    current = region
                    next = regions.next()
                }

                for _: Int in 0 ..< current.indent * indent {
                    $0.append(" ")
                }

                $0 += line.text
            }

            $0.append("\n")
        }
    }

    private static func lines(of source: String) -> [BlockIndentableLine?] {
        let lines: [Substring] = source.split(
            omittingEmptySubsequences: false,
            whereSeparator: \.isNewline
        )
        return lines.map {
            guard
            let start: String.Index = $0.firstIndex(where: { !$0.isWhitespace }),
            let last: String.Index = $0.lastIndex(where: { !$0.isWhitespace }) else {
                return nil
            }

            let text: Substring = $0[start ... last]

            guard
            let start: String.Index = start.samePosition(in: source.utf8) else {
                fatalError("could not convert string index to utf8 offset!!!")
            }

            return .init(
                start: source.utf8.distance(from: source.utf8.startIndex, to: start),
                text: text
            )
        }
    }
}
