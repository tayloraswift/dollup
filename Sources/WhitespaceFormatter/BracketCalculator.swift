import SwiftSyntax

final class BracketCalculator: SyntaxVisitor {
    private(set) var brackets: [AbsolutePosition: BracketSide]

    private let style: BraceStyle
    private var stack: [Scope]
    private var line: UInt

    init(style: BraceStyle) {
        self.brackets = [:]

        self.style = style
        self.stack = []
        self.line = 0
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: StringLiteralExprSyntax) -> SyntaxVisitorContinueKind {
        guard case .multilineStringQuote = node.openingQuote.tokenKind else {
            return .visitChildren
        }

        self.skip((node.openingPounds ?? node.openingQuote).leadingTrivia)
        self.push(node.openingPounds ?? node.openingQuote, type: .quotes)
        self.skip(node.openingQuote.trailingTrivia)

        self.walk(node.segments)

        self.skip(node.closingQuote.leadingTrivia)
        self.pop(node.closingQuote, type: .quotes)
        self.skip(node.closingQuote.trailingTrivia)

        return .skipChildren
    }

    override func visit(_ node: IfExprSyntax) -> SyntaxVisitorContinueKind {
        if  let elseKeyword: TokenSyntax = node.elseKeyword {
            self.brackets[elseKeyword.positionAfterSkippingLeadingTrivia] = .bridging
        }
        return .visitChildren
    }
    override func visit(_ node: DoStmtSyntax) -> SyntaxVisitorContinueKind {
        for catchClause: CatchClauseSyntax in node.catchClauses {
            let catchKeyword: TokenSyntax = catchClause.catchKeyword
            self.brackets[catchKeyword.positionAfterSkippingLeadingTrivia] = .bridging
        }
        return .visitChildren
    }
    override func visit(_ node: GuardStmtSyntax) -> SyntaxVisitorContinueKind {
        self.brackets[node.elseKeyword.positionAfterSkippingLeadingTrivia] = .bridging
        return .visitChildren
    }
    override func visit(_ node: RepeatStmtSyntax) -> SyntaxVisitorContinueKind {
        self.brackets[node.whileKeyword.positionAfterSkippingLeadingTrivia] = .bridging
        return .visitChildren
    }

    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        self.skip(token.leadingTrivia)

        switch token.tokenKind {
        case .leftBrace:
            self.push(token, type: .brace)
        case .leftSquare:
            self.push(token, type: .square)
        case .leftParen:
            self.push(token, type: .parenthesis)

        case .rightBrace:
            self.pop(token, type: .brace)
        case .rightSquare:
            self.pop(token, type: .square)
        case .rightParen:
            self.pop(token, type: .parenthesis)
        default:
            break
        }

        self.skip(token.trailingTrivia)
        return .skipChildren
    }
}
extension BracketCalculator {
    /// Despite official documentation, newlines can and do appear in trailing trivia.
    /// One example is the trailing newline after a multiline opening string quote.
    private func skip(_ trivia: Trivia) {
        for piece: TriviaPiece in trivia {
            // we don’t care about absolute line numbers, we just want to know if we crossed
            // a line boundary
            switch piece {
            case .carriageReturnLineFeeds: self.line += 1
            case .newlines: self.line += 1
            default: continue
            }
        }
    }
    private func push(_ token: TokenSyntax, type: BracketType) {
        // an opening delimiter is immovable if it is the first token in its parent, and also
        // the first token in its grandparent
        let position: AbsolutePosition = token.positionAfterSkippingLeadingTrivia
        let soft: Bool

        softness:
        if  let parent: Syntax = token.parent,
            case position = parent.positionAfterSkippingLeadingTrivia,
            var grandparent: Syntax = parent.parent,
            case position = grandparent.positionAfterSkippingLeadingTrivia {

            while let container: Syntax = grandparent.parent,
                container.is(SwitchCaseItemSyntax.self) ||
                container.is(ExpressionPatternSyntax.self) ||
                container.is(OptionalTypeSyntax.self) ||
                container.is(OptionalChainingExprSyntax.self) {

                if  case position = container.positionAfterSkippingLeadingTrivia {
                    grandparent = container
                } else {
                    soft = self.style.moves(type)
                    break softness
                }
            }

            // bracket is hard, and it is not inside something that could turn it soft
            // by going up one more level in the AST
            soft = false
        } else {
            soft = self.style.moves(type)
        }

        self.stack.append(
            .init(
                type: type,
                soft: soft,
                line: self.line,
                open: token.positionAfterSkippingLeadingTrivia
            )
        )
    }
    private func pop(_ token: TokenSyntax, type: BracketType) {
        guard let scope: Scope = self.stack.popLast() else {
            return
        }

        let position: AbsolutePosition = token.positionAfterSkippingLeadingTrivia

        guard case type = scope.type else {
            fatalError(
                "[\(position)]: mismatched delimiter, expected '\(scope.type)', got '\(type)'"
            )
        }

        if  scope.soft, scope.line < self.line {
            // delimiters are movable if they are on a different line
            // than their opening delimiter
            self.brackets[scope.open] = .opening
            self.brackets[position] = .closing
        }
    }
}
