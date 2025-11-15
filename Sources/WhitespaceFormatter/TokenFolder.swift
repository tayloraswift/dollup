import SwiftSyntax

class TokenFolder: SyntaxRewriter {
    private let movable: [AbsolutePosition: Bool]

    init(movable: [AbsolutePosition: Bool]) {
        self.movable = movable
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: TokenSyntax) -> TokenSyntax {
        if  let space: Bool = self.movable[node.positionAfterSkippingLeadingTrivia] {
            self.align(node: node, separator: space ? self.separator : nil)
        } else {
            node
        }
    }
}
extension TokenFolder: VerticalRewriter {
    var separator: TriviaPiece { .spaces(1) }
}
