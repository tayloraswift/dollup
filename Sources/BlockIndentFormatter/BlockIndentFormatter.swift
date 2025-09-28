import SwiftOperators
import SwiftParser
import SwiftSyntax

/// This pass detects Google-style “code rectangles”, and reformats Swift code to fit within a
/// specified maximum line length.
public struct BlockIndentFormatter {
    private let operators: OperatorTable

    private init(operators: OperatorTable) {
        self.operators = operators
    }
}
extension BlockIndentFormatter {
    public static func reformat(
        _ source: inout String,
        indent: Int,
        width: Int,
        check: Bool = true
    ) {
        let formatter: Self = .init(operators: .standardOperators)
        formatter.reformat(&source, indent: indent, width: width, check: check)
    }

    public static func reindent(_ source: String, by indent: Int) -> String {
        let formatter: Self = .init(operators: .standardOperators)
        return formatter.reindent(source, by: indent)
    }
}
extension BlockIndentFormatter {
    private func parse(source: String) -> Syntax {
        do {
            return try self.operators.foldAll(Parser.parse(source: source))
        } catch {
            fatalError("failed to parse source!!! \(error)")
        }
    }

    private func reformat(
        _ source: inout String,
        indent: Int,
        width: Int,
        check: Bool,
    ) {
        let original: Syntax? = check ? self.parse(source: source) : nil
        var tree: Syntax

        // it would not make much sense to check for line length violations if the indentation
        // were not correct
        source = self.reindent(source, by: indent)
        tree = self.parse(source: source)

        while true {
            let visitor: BlockIndentWrapper = .init(text: source, width: width)

            visitor.walk(tree)

            if  visitor.linebreaks.isEmpty {
                break
            }

            var linebroken: String = ""
            var i: String.Index = source.startIndex
            for j: Linebreak in visitor.linebreaks {
                linebroken += source[i ..< j.index]
                linebroken.append("\(j.type)")
                i = j.index
            }
            if  i < source.endIndex {
                linebroken += source[i ..< source.endIndex]
            }

            source = self.reindent(linebroken, by: indent)
            tree = self.parse(source: source)
        }

        guard
        let original: TokenSequence = original?.tokens(viewMode: .sourceAccurate) else {
            return
        }

        // perform integrity check
        var expected: TokenSequence.Iterator = original.makeIterator()
        var rawQuote: String? = nil

        for token in tree.tokens(viewMode: .sourceAccurate) {
            guard let original: TokenSyntax = expected.next() else {
                fatalError("reformatted source has more tokens than original!!!")
            }

            if case .rawStringPoundDelimiter(let pattern) = token.tokenKind {
                if  let opening: String = rawQuote {
                    if  opening != pattern {
                        fatalError("mismatched raw string delimiters!!!")
                    }
                    rawQuote = nil
                } else {
                    rawQuote = pattern
                }
            }

            if token.trimmed.text == original.trimmed.text {
                continue
            }

            switch (original.tokenKind, token.tokenKind) {
            case (.stringQuote, .multilineStringQuote):
                // allow replacing `"` with `"""`
                continue

            case (.stringSegment(let before), .stringSegment(let after)):
                if case _? = rawQuote {
                    // if we got here, we have mismatched raw string delimiters, and
                    // normalization is not applicable
                    fallthrough
                }

                let before: [Unicode.Scalar] = .decode(literal: before)
                let after: [Unicode.Scalar] = .decode(literal: after)

                guard before == after else {
                    fallthrough
                }

            default:
                fatalError(
                    """
                    reformatted source does not match original!!!
                    expected: \(original.trimmed.text.debugDescription)
                    found:    \(token.trimmed.text.debugDescription)
                    """
                )
            }
        }

        guard case nil = expected.next() else {
            fatalError("reformatted source has fewer tokens than original!!!")
        }
    }

    private func reindent(_ source: String, by indent: Int) -> String {
        let tree: Syntax = self.parse(source: source)
        let calculator: BlockIndentCalculator = .init()

        calculator.walk(tree)

        var lines: [Line] = Self.lines(of: source)
        // because of how the indenter is written, it always adds a blank line at the end,
        // which is desirable, but also requires us to remove any trailing blank lines to
        // prevent the formatter from adding more and more blank lines at the end of the file
        while case true? = lines.last?.range.isEmpty {
            lines.removeLast()
        }
        return Self.indent(lines, in: calculator.regions, by: indent)
    }
}
extension BlockIndentFormatter {
    private static func indent(
        _ lines: [Line],
        in regions: [BlockIndentRegion],
        by indent: Int
    ) -> String {
        var regions: ([BlockIndentRegion].Iterator, [BlockIndentRegion].Iterator) = (
            regions.makeIterator(),
            regions.makeIterator()
        )

        var current: (BlockIndentRegion, BlockIndentRegion)

        if  let a: BlockIndentRegion = regions.0.next(),
            let b: BlockIndentRegion = regions.1.next() {
            current = (a, b)
        } else {
            fatalError("regions list is empty!!!")
        }

        var next: (BlockIndentRegion?, BlockIndentRegion?) = (
            regions.0.next(),
            regions.1.next()
        )

        return lines.reduce(into: "") {
            while let region: BlockIndentRegion = next.0,
                region.start <= $1.range.lowerBound {
                current.0 = region
                next.0 = regions.0.next()
            }
            while let region: BlockIndentRegion = next.1,
                region.start <= $1.range.upperBound {
                current.1 = region
                next.1 = regions.1.next()
            }

            for _: Int in 0 ..< current.0.indent * indent {
                $0.append(" ")
            }
            if  let whitespace: Substring = current.0.prefix {
                $0 += whitespace
            }

            $0 += $1.text

            escaping:
            if  let whitespace: Substring = current.1.suffix {
                guard current.1.escapable else {
                    $0 += whitespace
                    break escaping
                }

                let last: String.Index = whitespace.index(before: whitespace.endIndex)
                switch whitespace[last] {
                case " ":
                    // this would be unlikely to survive editor trimming
                    $0 += whitespace[..<last]
                    $0 += "\\u{20}"
                case "\t":
                    $0 += whitespace[..<last]
                    $0 += "\\t"
                default:
                    $0 += whitespace
                }
            }

            $0.append("\n")
        }
    }

    private static func lines(of source: String) -> [Line] {
        let lines: [Substring] = source.split(
            omittingEmptySubsequences: false,
            whereSeparator: \.isNewline
        )
        return lines.map {
            let range: Range<String.Index>

            if  let first: String.Index = $0.firstIndex(where: { !$0.isWhitespace }),
                let last: String.Index = $0.lastIndex(where: { !$0.isWhitespace }) {
                range = first ..< $0.index(after: last)
            } else {
                range = $0.startIndex ..< $0.startIndex
            }

            let text: Substring = $0[range]

            guard
            let start: String.Index = range.lowerBound.samePosition(in: source.utf8),
            let end: String.Index = range.upperBound.samePosition(in: source.utf8) else {
                fatalError("could not convert string index to utf8 offset!!!")
            }

            return .init(
                range: source.utf8.distance(from: source.utf8.startIndex, to: start)
                    ..< source.utf8.distance(from: source.utf8.startIndex, to: end),
                text: text
            )
        }
    }
}
