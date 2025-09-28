import SwiftSyntax
import SwiftParser

/// This pass detects Google-style “code rectangles”, and reformats Swift code to fit within a
/// specified maximum line length.
public struct BlockIndentFormatter {
    public static func reformat(_ source: inout String, indent: Int, width: Int) {
        // it would not make much sense to check for line length violations if the indentation
        // were not correct
        source = self.reindent(source, by: indent)

        while true {
            let tree: SourceFileSyntax = Parser.parse(source: source)
            let visitor: BlockIndentWrapper = .init(text: source, width: width)

            visitor.walk(tree)

            if  visitor.linebreaks.isEmpty {
                break
            }

            var linebroken: String = ""
            var i: String.Index = source.startIndex
            for j: String.Index in visitor.linebreaks {
                linebroken += source[i ..< j]
                linebroken.append("\n")
                i = j
            }
            if  i < source.endIndex {
                linebroken += source[i ..< source.endIndex]
            }

            source = self.reindent(linebroken, by: indent)
        }
    }

    public static func reindent(_ source: String, by indent: Int) -> String {
        let tree: SourceFileSyntax = Parser.parse(source: source)
        let calculator: BlockIndentCalculator = .init()

        calculator.walk(tree)

        var lines: [BlockIndentableLine?] = Self.lines(of: source)
        // because of how the indenter is written, it always adds a blank line at the end,
        // which is desirable, but also requires us to remove any trailing blank lines to
        // prevent the formatter from adding more and more blank lines at the end of the file
        while case nil = lines.last {
            lines.removeLast()
        }
        return Self.indent(lines, in: calculator.regions, by: indent)
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
