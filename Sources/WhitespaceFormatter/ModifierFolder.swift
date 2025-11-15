import SwiftSyntax

final class ModifierFolder: SyntaxRewriter {
    private let movable: Set<AbsolutePosition>

    init(movable: Set<AbsolutePosition>) {
        self.movable = movable
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: TokenSyntax) -> TokenSyntax {
        switch node.tokenKind {
        case .atSign, .keyword:
            if  self.movable.contains(node.positionAfterSkippingLeadingTrivia) {
                return self.align(node: node)
            }
        default:
            break
        }

        return node
    }
}
extension ModifierFolder: VerticalRewriter {
    var separator: TriviaPiece { .spaces(1) }
}
