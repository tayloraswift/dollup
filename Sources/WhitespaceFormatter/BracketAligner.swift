import SwiftSyntax

class BracketAligner: SyntaxRewriter {
    private let brackets: [AbsolutePosition: BracketSide]
    private let style: BraceStyle

    init(style: BraceStyle, brackets: [AbsolutePosition: BracketSide]) {
        self.brackets = brackets
        self.style = style
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(
        _ node: MultipleTrailingClosureElementSyntax
    ) -> MultipleTrailingClosureElementSyntax {
        // important to pass the node *before* its children were rewritten, because the
        // rewritten children may have non-canonical trivia
        super.visit(node).with(\.label, self.align(node: node.label))
    }

    override func visit(_ node: TokenSyntax) -> TokenSyntax {
        switch node.tokenKind {
        case .leftBrace: self.alignAsOpening(node: node)
        case .leftSquare: self.alignAsOpening(node: node)
        case .leftParen: self.alignAsOpening(node: node)
        case .multilineStringQuote: self.alignAsOpening(node: node)
        case .rawStringPoundDelimiter: self.alignAsOpening(node: node)
        case .keyword(.else): self.alignToClosing(node: node)
        case .keyword(.catch): self.alignToClosing(node: node)
        case .keyword(.while): self.alignToClosing(node: node)
        default: node
        }
    }
}
extension BracketAligner {
    private func alignAsOpening(node: TokenSyntax) -> TokenSyntax {
        if  case .opening? = self.brackets[node.positionAfterSkippingLeadingTrivia] {
            return self.align(node: node)
        } else {
            return node
        }
    }
    private func alignToClosing(node: TokenSyntax) -> TokenSyntax {
        if  case .bridging? = self.brackets[node.positionAfterSkippingLeadingTrivia],
            let query: TokenSyntax = node.previousToken(viewMode: .sourceAccurate),
            case .closing? = self.brackets[query.positionAfterSkippingLeadingTrivia] {
            return self.align(node: node)
        } else {
            return node
        }
    }
    private func align<Node>(node: Node) -> Node where Node: SyntaxProtocol {
        if  let i: Int = Self.cutTrivia(node.leadingTrivia) {
            //  if the line comment has a newline after it, it could be end of file, but how?
            if  i >= node.leadingTrivia.endIndex {
                fatalError("line comment at end of leading trivia?!?!")
            }

            let keptTrivia: Trivia  = .init(pieces: node.leadingTrivia[...i])
            let newTrivia: Trivia
            switch node.leadingTrivia[i] {
            case .carriageReturnLineFeeds, .newlines:
                newTrivia = keptTrivia
            default:
                newTrivia = keptTrivia.appending(self.style.before)
            }

            return node.with(\.leadingTrivia, newTrivia)
        } else if let previous: TokenSyntax = node.previousToken(viewMode: .sourceAccurate) {
            // either all trivia is to be removed, or there was no trivia to begin with.
            // check the previous token to see if it has trailing whitespace, if not, insert a
            // a space before the node, which is non-canonical, but will be reattributed on
            // the next re-parse
            let padding: Trivia
            if  case .egyptian = self.style,
                case .spaces? = previous.trailingTrivia.pieces.last {
                padding = []
            } else if
                case .egyptian = self.style, node.leadingTrivia.isEmpty {
                padding = []
            } else {
                padding = [self.style.before]
            }

            return node.with(\.leadingTrivia, padding)
        } else {
            return node.with(\.leadingTrivia, [])
        }
    }

    /// Returns the index of the last trivia piece to keep, or `nil` if all trivia pieces should
    /// be removed.
    private static func cutTrivia(_ pieces: Trivia) -> Int? {
        for i: Int in pieces.indices.reversed() {
            switch pieces[i] {
            case .backslashes: return i
            case .blockComment: return i
            case .carriageReturns: continue
            case .carriageReturnLineFeeds: continue
            case .docBlockComment: return i
            case .docLineComment: return pieces.index(after: i)
            case .formfeeds: return i
            case .lineComment: return pieces.index(after: i)
            case .newlines: continue
            case .pounds: return i
            case .spaces: continue
            case .tabs: continue
            case .unexpectedText: return i
            case .verticalTabs: continue
            }
        }
        return nil
    }
}
