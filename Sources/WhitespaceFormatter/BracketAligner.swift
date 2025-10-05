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
extension BracketAligner: VerticalRewriter {
    var separator: TriviaPiece { self.style.before }
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
        if  case .bridging? = self.brackets[node.positionAfterSkippingLeadingTrivia] {
            return self.align(node: node)
        } else {
            return node
        }
    }
}
