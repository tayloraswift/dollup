import SwiftSyntax

protocol VerticalFolder {
    var separator: TriviaPiece { get }
    /// Returns `true` if the node should be pulled up with a ``separator`` between it and the
    /// previous token, `false` if it should be pulled up with no whitespace between it and the
    /// previous token, or `nil` if it should not be pulled up at all.
    func fold(_ node: TokenSyntax) -> Bool?
}
extension VerticalFolder {
    func rewrite(_ node: some SyntaxProtocol) -> String {
        var settled: [TokenSyntax] = []
        var pending: TokenSyntax? = nil
        for node: TokenSyntax in node.tokens(viewMode: .sourceAccurate) {
            var current: TokenSyntax = node.detached
            if  let separator: Bool = self.fold(node) {
                Self.align(
                    &pending,
                    &current,
                    separator: separator ? self.separator : nil
                )
            }

            if  let pending: TokenSyntax {
                settled.append(pending)
            }
            pending = current
        }
        if  let pending: TokenSyntax {
            settled.append(pending)
        }

        return settled.lazy.map(\.description).joined()
    }
}
extension VerticalFolder {
    /// Pulls “up” the node by removing newlines between it and the previous token. If this
    /// would result in no whitespace between the two tokens, a single instance of ``separator``
    /// is inserted instead, if it is non-nil.
    private static func align(
        _ pending: inout TokenSyntax?,
        _ current: inout TokenSyntax,
        separator: TriviaPiece?
    ) {
        if  let i: Int = Self.cutTrivia(current.leadingTrivia) {
            //  if the line comment has a newline after it, it could be end of file, but how?
            if  i >= current.leadingTrivia.endIndex {
                fatalError("line comment at end of leading trivia?!?!")
            }

            let keptTrivia: Trivia  = .init(pieces: current.leadingTrivia[...i])
            let newTrivia: Trivia
            switch current.leadingTrivia[i] {
            case .carriageReturnLineFeeds, .newlines:
                newTrivia = keptTrivia
            default:
                if  let separator: TriviaPiece {
                    newTrivia = keptTrivia.appending(separator)
                } else {
                    newTrivia = keptTrivia
                }
            }

            current.leadingTrivia = newTrivia
        } else if
            let previous: TokenSyntax = pending,
            let separator: TriviaPiece = separator {
            // either all trivia is to be removed, or there was no trivia to begin with.
            // check the previous token to see if it has trailing whitespace, if not, insert a
            // a space before the node
            let padding: Trivia
            if  case .spaces = separator,
                case .spaces? = previous.trailingTrivia.pieces.last {
                padding = []
            } else if
                case .spaces = separator, current.leadingTrivia.isEmpty {
                padding = []
            } else {
                padding = [separator]
            }

            current.leadingTrivia = padding

            // if the previous token ends with a line comment, and we’re padding with spaces,
            // we need to turn that line comment into a block comment
            lookback:
            if  case .spaces = separator,
                let last: Int = previous.trailingTrivia.pieces.indices.last {
                let newComment: TriviaPiece
                switch previous.trailingTrivia.pieces[last] {
                case .lineComment(let text):
                    newComment = .blockComment("/*\(text.dropFirst(2))*/")
                case .docLineComment(let text):
                    newComment = .docBlockComment("/**\(text.dropFirst(3))*/")
                default:
                    break lookback
                }

                let keptTrivia: Trivia = .init(pieces: previous.trailingTrivia[..<last])
                pending?.trailingTrivia = keptTrivia.appending(newComment)
            }
        } else {
            current.leadingTrivia = []
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
