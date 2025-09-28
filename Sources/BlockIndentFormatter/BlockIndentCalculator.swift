import SwiftSyntax
import SwiftParser

class BlockIndentCalculator: SyntaxVisitor {
    private(set) var regions: [BlockIndentRegion]
    private var level: Int

    init() {
        self.regions = [.init(start: 0, indent: 0, prefix: nil, suffix: nil)]
        self.level = 0
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: AccessorBlockSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftBrace)
        self.walk(node.accessors)
        self.deindent(before: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftBrace)
        self.walk(node.statements)
        self.deindent(before: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: MemberBlockSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftBrace)
        self.walk(node.members)
        self.deindent(before: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftBrace)
        self.walkIfPresent(node.signature)
        self.walk(node.statements)
        self.deindent(before: node.rightBrace)
        return .skipChildren
    }

    override func visit(_ node: ArrayExprSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftSquare)
        self.walk(node.elements)
        self.deindent(before: node.rightSquare)
        return .skipChildren
    }
    override func visit(_ node: DictionaryExprSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftSquare)
        self.walk(node.content)
        self.deindent(before: node.rightSquare)
        return .skipChildren
    }

    override func visit(_ node: TupleExprSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftParen)
        self.walk(node.elements)
        self.deindent(before: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: TuplePatternSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftParen)
        self.walk(node.elements)
        self.deindent(before: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftParen)
        self.walk(node.elements)
        self.deindent(before: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        self.walk(node.atSign)
        self.walk(node.attributeName)
        if let left: TokenSyntax = node.leftParen {
            self.indent(after: left)
        }
        self.walkIfPresent(node.arguments)
        if let right: TokenSyntax = node.rightParen {
            self.deindent(before: right)
        }
        return .skipChildren
    }
    override func visit(_ node: ClosureParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftParen)
        self.walk(node.parameters)
        self.deindent(before: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: EnumCaseParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftParen)
        self.walk(node.parameters)
        self.deindent(before: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: FunctionParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftParen)
        self.walk(node.parameters)
        self.deindent(before: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(node.calledExpression)

        if  let left: TokenSyntax = node.leftParen {
            self.indent(after: left)
        }

        self.walk(node.arguments)

        if let right: TokenSyntax = node.rightParen {
            self.deindent(before: right)
        }

        self.walkIfPresent(node.trailingClosure)
        self.walkIfPresent(node.additionalTrailingClosures)

        return .skipChildren
    }
    override func visit(_ node: MacroExpansionExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(node.pound)
        self.walk(node.macroName)
        self.walkIfPresent(node.genericArgumentClause)

        if  let left: TokenSyntax = node.leftParen {
            self.indent(after: left)
        }

        self.walk(node.arguments)

        if let right: TokenSyntax = node.rightParen {
            self.deindent(before: right)
        }

        self.walkIfPresent(node.trailingClosure)
        self.walkIfPresent(node.additionalTrailingClosures)

        return .skipChildren
    }

    override func visit(_ node: GenericArgumentClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftAngle)
        self.walk(node.arguments)
        self.deindent(before: node.rightAngle)
        return .skipChildren
    }
    override func visit(_ node: GenericParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftAngle)
        self.walk(node.parameters)
        self.walkIfPresent(node.genericWhereClause)
        self.deindent(before: node.rightAngle)
        return .skipChildren
    }
    override func visit(_ node: PrimaryAssociatedTypeClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.leftAngle)
        self.walk(node.primaryAssociatedTypes)
        self.deindent(before: node.rightAngle)
        return .skipChildren
    }

    override func visit(_ node: IfExprSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.ifKeyword)

        self.walk(node.conditions)

        self.outdent(token: node.body.leftBrace)

        self.walk(node.body.statements)

        self.deindent(before: node.body.rightBrace)

        guard
        let elseKeyword: TokenSyntax = node.elseKeyword,
        let elseBody: IfExprSyntax.ElseBody = node.elseBody else {
            return .skipChildren
        }

        self.walk(elseKeyword)
        switch elseBody {
        case .ifExpr(let elseIf):
            self.walk(elseIf)

        case .codeBlock(let codeBlock):
            self.indent(after: codeBlock.leftBrace)
            self.walk(codeBlock.statements)
            self.deindent(before: codeBlock.rightBrace)
        }

        return .skipChildren
    }

    override func visit(_ node: ForStmtSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.forKeyword)

        self.walkIfPresent(node.tryKeyword)
        self.walkIfPresent(node.awaitKeyword)
        self.walkIfPresent(node.unsafeKeyword)
        self.walkIfPresent(node.caseKeyword)
        self.walk(node.pattern)
        self.walkIfPresent(node.typeAnnotation)
        self.walk(node.inKeyword)
        self.walk(node.sequence)
        self.walkIfPresent(node.whereClause)

        self.outdent(token: node.body.leftBrace)

        self.walk(node.body.statements)

        self.deindent(before: node.body.rightBrace)
        return .skipChildren
    }

    override func visit(_ node: WhileStmtSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.whileKeyword)

        self.walk(node.conditions)

        self.outdent(token: node.body.leftBrace)

        self.walk(node.body.statements)

        self.deindent(before: node.body.rightBrace)

        return .skipChildren
    }

    override func visit(_ node: RepeatStmtSyntax) -> SyntaxVisitorContinueKind {
        self.walk(node.repeatKeyword)

        self.indent(after: node.body.leftBrace)
        self.walk(node.body.statements)
        self.deindent(before: node.body.rightBrace)

        self.walk(node.whileKeyword)
        self.walk(node.condition)

        return .skipChildren
    }

    override func visit(_ node: SwitchCaseSyntax) -> SyntaxVisitorContinueKind {
        self.walkIfPresent(node.attribute)
        switch node.label {
        case .case(let patterns):
            self.indent(after: patterns.caseKeyword)
            self.walk(patterns.caseItems)
            self.walk(patterns.colon)
            self.walk(node.statements)

        case .default(let label):
            self.indent(after: label.defaultKeyword)
            self.walk(label.colon)
            self.walk(node.statements)
        }
        self.walk(node.statements)
        self.deindent(at: node.statements.endPosition)
        return .skipChildren
    }

    override func visit(_ node: StringSegmentSyntax) -> SyntaxVisitorContinueKind {
        var content: Substring = node.content.text[...]
        // the trailing newline is handled by the line-based reindenter
        if case "\n"? = content.last {
            content.removeLast()
        }

        let whitespaceLeft: Substring
        let whitespaceRight: Substring

        if  let last: String.Index = content.lastIndex(where: { !$0.isWhitespace }) {
            let i: String.Index = content.index(after: last)

            whitespaceLeft = content.prefix(while: \.isWhitespace)
            whitespaceRight = content[i...]
        } else {
            // if the string segment is all whitespace, it is considered a suffix, not a prefix
            whitespaceLeft = ""
            whitespaceRight = content[...]
        }

        if !whitespaceLeft.isEmpty || !whitespaceRight.isEmpty {
            self.region(
                start: node.positionAfterSkippingLeadingTrivia,
                delta: 0,
                prefix: whitespaceLeft.isEmpty ? nil : whitespaceLeft,
                suffix: whitespaceRight.isEmpty ? nil : whitespaceRight
            )
            self.region(
                start: node.endPositionBeforeTrailingTrivia,
                delta: 0,
                prefix: nil,
                suffix: nil
            )
        }

        // this node has no children to walk
        return .visitChildren
    }

    override func visit(_ node: BinaryOperatorExprSyntax) -> SyntaxVisitorContinueKind {
        self.indent(token: node.operator)
        return .skipChildren
    }
    override func visit(_ node: TernaryExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(node.condition)
        self.indent(token: node.questionMark)
        self.walk(node.thenExpression)
        self.indent(token: node.colon)
        self.walk(node.elseExpression)
        return .skipChildren
    }

    override func visit(_ node: GenericWhereClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.whereKeyword)
        self.walk(node.requirements)
        self.deindent(at: node.requirements.endPosition)
        return .skipChildren
    }
    override func visit(_ node: InheritanceClauseSyntax) -> SyntaxVisitorContinueKind {
        self.indent(after: node.colon)
        self.walk(node.inheritedTypes)
        self.deindent(at: node.inheritedTypes.endPosition)
        return .skipChildren
    }
}
extension BlockIndentCalculator {
    private func walkIfPresent<Node>(_ node: Node?) where Node: SyntaxProtocol {
        if  let node: Node {
            self.walk(node)
        }
    }

    private func outdent(token: TokenSyntax) {
        self.region(start: token.positionAfterSkippingLeadingTrivia, delta: -1)
        self.region(start: token.endPosition, delta: +1)
    }
    private func indent(token: TokenSyntax) {
        self.region(start: token.positionAfterSkippingLeadingTrivia, delta: +1)
        self.region(start: token.endPosition, delta: -1)
    }
    private func indent(after left: TokenSyntax) {
        // TokenSyntax has no children to walk
        self.region(start: left.endPosition, delta: +1)
    }
    private func deindent(before right: TokenSyntax) {
        self.region(start: right.positionAfterSkippingLeadingTrivia, delta: -1)
    }
    private func deindent(at position: AbsolutePosition) {
        self.region(start: position, delta: -1)
    }

    private func region(
        start: AbsolutePosition,
        delta: Int,
        prefix: Substring? = nil,
        suffix: Substring? = nil
    ) {
        self.level += delta
        self.regions.append(.init(start: start.utf8Offset, indent: self.level, prefix: prefix, suffix: suffix))
    }
}
