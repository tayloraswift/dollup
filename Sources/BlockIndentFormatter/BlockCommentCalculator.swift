import SwiftSyntax

struct BlockCommentCalculator: ~Copyable {
    private(set) var regions: [BlockCommentRegion] = []

    init() {
        // starting from -1 allows us to handle the special (but common?) case of a block
        // comment at the start of the file
        self.regions.append(.init(start: -1, comment: false))
    }
}
extension BlockCommentCalculator {
    mutating func walk(_ tree: Syntax) {
        for token: TokenSyntax in tree.tokens(viewMode: .sourceAccurate) {
            self.iterate(token: token)
        }
    }
}
extension BlockCommentCalculator {
    private mutating func iterate(token: TokenSyntax) {
        self.iterate(trivia: token.leadingTrivia, at: token.position)
        self.iterate(trivia: token.trailingTrivia, at: token.endPositionBeforeTrailingTrivia)
    }

    private mutating func iterate(trivia: Trivia, at cursor: consuming AbsolutePosition) {
        for trivia: TriviaPiece in trivia {
            let triviaLength: SourceLength = trivia.sourceLength
            defer {
                cursor += triviaLength
            }

            let startOffset: Int

            switch trivia {
            case .blockComment:
                startOffset = cursor.utf8Offset + 2
            case .docBlockComment:
                startOffset = cursor.utf8Offset + 3
            default:
                continue
            }

            // mark this region as a comment
            let start: BlockCommentRegion = .init(
                start: startOffset,
                comment: true
            )
            let end: BlockCommentRegion = .init(
                start: cursor.utf8Offset + triviaLength.utf8Length - 2,
                comment: false
            )

            self.regions.append(start)
            self.regions.append(end)
        }
    }
}
