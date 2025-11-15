import SwiftSyntax

protocol VerticalRewriter: SyntaxRewriter {
    var separator: TriviaPiece { get }
}
extension VerticalRewriter {
    /// Pulls “up” the node by removing newlines between it and the previous token. If this
    /// would result in no whitespace between the two tokens, a single instance of ``separator``
    /// is inserted instead, if it is non-nil.
    func align<Node>(node: Node) -> Node where Node: SyntaxProtocol {
        self.align(node: node, separator: self.separator)
    }

    func align<Node>(node: Node, separator: TriviaPiece?) -> Node where Node: SyntaxProtocol {
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
                if  let separator: TriviaPiece {
                    newTrivia = keptTrivia.appending(separator)
                } else {
                    newTrivia = keptTrivia
                }
            }

            return node.with(\.leadingTrivia, newTrivia)
        } else if
            let previous: TokenSyntax = node.previousToken(viewMode: .sourceAccurate),
            let separator: TriviaPiece = separator {
            // either all trivia is to be removed, or there was no trivia to begin with.
            // check the previous token to see if it has trailing whitespace, if not, insert a
            // a space before the node, which is non-canonical, but will be reattributed on
            // the next re-parse
            let padding: Trivia
            if  case .spaces = separator,
                case .spaces? = previous.trailingTrivia.pieces.last {
                padding = []
            } else if
                case .spaces = separator, node.leadingTrivia.isEmpty {
                padding = []
            } else {
                padding = [separator]
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
