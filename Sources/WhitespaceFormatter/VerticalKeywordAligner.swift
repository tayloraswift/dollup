import SwiftSyntax

class VerticalKeywordAligner: SyntaxRewriter {
    private let movable: Set<AbsolutePosition>

    init(movable: Set<AbsolutePosition>) {
        self.movable = movable
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: TokenSyntax) -> TokenSyntax {
        if  case .keyword = node.tokenKind,
            movable.contains(node.positionAfterSkippingLeadingTrivia) {
            return self.align(node: node)
        } else {
            return node
        }
    }
}
extension VerticalKeywordAligner: VerticalRewriter {
    var separator: TriviaPiece { .spaces(1) }
}
