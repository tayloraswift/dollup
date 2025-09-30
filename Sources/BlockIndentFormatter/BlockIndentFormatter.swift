import SwiftOperators
import SwiftParser
import SwiftSyntax

/// This pass detects Google-style “code rectangles”, and reformats Swift code to fit within a
/// specified maximum line length.
public struct BlockIndentFormatter {
    private let operators: OperatorTable
    private let indentIfConfig: Bool

    private init(operators: OperatorTable, indentIfConfig: Bool) {
        self.operators = operators
        self.indentIfConfig = indentIfConfig
    }
}
extension BlockIndentFormatter {
    public static func reformat(
        _ source: inout String,
        indent: Int,
        width: Int,
        check: Bool = true,
        _indentIfConfig: Bool = false,
    ) {
        let formatter: Self = .init(
            operators: .standardOperators,
            indentIfConfig: _indentIfConfig
        )
        formatter.reformat(&source, indent: indent, width: width, check: check)
    }

    public static func reindent(_ source: String, by indent: Int) -> String {
        let formatter: Self = .init(operators: .standardOperators, indentIfConfig: true)
        return formatter.reindent(source, by: indent)
    }
}
extension BlockIndentFormatter {
    private func parse(source: String) -> Syntax {
        self.operators.foldAll(Parser.parse(source: source)) {
            print("operator folding error: \($0)")
        }
    }

    private func reformat(
        _ source: inout String,
        indent: Int,
        width: Int,
        check: Bool
    ) {
        let original: Syntax? = check ? self.parse(source: source) : nil
        var tree: Syntax

        let expander: LineExpander = .init(text: source)
        ;   expander.walk(original ?? self.parse(source: source))
        if !expander.linebreaks.isEmpty {
            source = source.insert(linebreaks: expander.linebreaks)
        }

        // it would not make much sense to check for line length violations if the indentation
        // were not correct
        source = self.reindent(source, by: indent)
        tree = self.parse(source: source)

        while true {
            let wrapper: LineWrapper = .init(text: source, width: width)
            ;   wrapper.walk(tree)

            if  wrapper.linebreaks.isEmpty {
                break
            }

            source = self.reindent(source.insert(linebreaks: wrapper.linebreaks), by: indent)
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
        let indents: BlockIndentCalculator = .init(indentIfConfig: self.indentIfConfig)
        ;   indents.walk(tree)

        var exclude: BlockCommentCalculator = .init()
        ;   exclude.walk(tree)

        var lines: [Line] = Self.lines(of: source)
        // because of how the indenter is written, it always adds a blank line at the end,
        // which is desirable, but also requires us to remove any trailing blank lines to
        // prevent the formatter from adding more and more blank lines at the end of the file
        while case true? = lines.last?.range.isEmpty {
            lines.removeLast()
        }

        return Self.indent(
            lines: lines,
            by: indent,
            indents: indents.regions,
            exclude: exclude.regions,
        )
    }
}

extension BlockIndentFormatter {
    private static func indent(
        lines: [Line],
        by indent: Int,
        indents: [BlockIndentRegion],
        exclude: [BlockCommentRegion],
    ) -> String {
        var regions: (
            [BlockIndentRegion].Iterator,
            [BlockIndentRegion].Iterator,
            exclude: [BlockCommentRegion].Iterator
        ) = (
            indents.makeIterator(),
            indents.makeIterator(),
            exclude.makeIterator()
        )

        var current: (BlockIndentRegion, BlockIndentRegion, exclude: BlockCommentRegion)

        if  let a: BlockIndentRegion = regions.0.next(),
            let b: BlockIndentRegion = regions.1.next(),
            let exclude: BlockCommentRegion = regions.exclude.next() {
            current = (a, b, exclude)
        } else {
            fatalError("regions list is empty!!!")
        }

        var next: (BlockIndentRegion?, BlockIndentRegion?, exclude: BlockCommentRegion?) = (
            regions.0.next(),
            regions.1.next(),
            regions.exclude.next()
        )

        return lines.reduce(into: "") {
            while let region: BlockCommentRegion = next.exclude,
                region.start <= $1.range.lowerBound {
                current.exclude = region
                next.exclude = regions.exclude.next()
            }
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

            if $1.range.isEmpty,
                case nil = current.0.prefix,
                case nil = current.1.suffix {
                // blank line, no prefix or suffix to preserve
            } else {
                let spaces: Int = current.exclude.comment
                    ? $1.column ?? 0
                    : current.0.indent * indent

                for _: Int in 0 ..< spaces {
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
            let column: Int?

            if  let first: String.Index = $0.firstIndex(where: { !$0.isWhitespace }),
                let last: String.Index = $0.lastIndex(where: { !$0.isWhitespace }) {
                range = first ..< $0.index(after: last)
                column = $0.distance(from: $0.startIndex, to: first)
            } else {
                range = $0.startIndex ..< $0.startIndex
                column = nil
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
                column: column,
                text: text,
            )
        }
    }
}
