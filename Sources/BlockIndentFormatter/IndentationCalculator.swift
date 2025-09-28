import SwiftSyntax
import SwiftParser

func _lines(of source: String) -> [IndentableLine] {
    let lines: [Substring] = source.split(
        omittingEmptySubsequences: false,
        whereSeparator: \.isNewline
    )
    return lines.map {
        guard
        let start: String.Index = $0.firstIndex(where: { !$0.isWhitespace }),
        let last: String.Index = $0.lastIndex(where: { !$0.isWhitespace }) else {
            return .init(start: nil, text: "")
        }

        let text: Substring = $0[start ... last]

        guard
        let start: String.Index = start.samePosition(in: source.utf8) else {
            fatalError("could not convert string index to utf8 offset!!!")
        }

        return .init(
            start: source.utf8.distance(from: source.utf8.startIndex, to: start),
            text: text
        )
    }
}

struct IndentableLine {
    /// UTF-8 byte offset where the first non-whitespace character appears.
    let start: Int?
    /// The content of the line, with all leading whitespace and trailing whitespace removed.
    /// Might be empty!
    let text: Substring
}
struct IndentationRegion {
    /// UTF-8 byte offset where this region starts.
    let start: Int
    /// Indentation level, in indentation units.
    let indent: Int
}

class IndentationCalculator: SyntaxVisitor {
    private(set) var regions: [IndentationRegion]
    private var level: Int

    init() {
        self.regions = []
        self.level = 0
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: AccessorBlockSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftBrace)
        self.walk(node.accessors)
        self.walk(deindenting: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftBrace)
        self.walk(node.statements)
        self.walk(deindenting: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: MemberBlockSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftBrace)
        self.walk(node.members)
        self.walk(deindenting: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftBrace)
        self.walk(node.statements)
        self.walk(deindenting: node.rightBrace)
        return .skipChildren
    }

    override func visit(_ node: ArrayExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftSquare)
        self.walk(node.elements)
        self.walk(deindenting: node.rightSquare)
        return .skipChildren
    }
    override func visit(_ node: DictionaryExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftSquare)
        self.walk(node.content)
        self.walk(deindenting: node.rightSquare)
        return .skipChildren
    }

    override func visit(_ node: TupleExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftParen)
        self.walk(node.elements)
        self.walk(deindenting: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: TuplePatternSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftParen)
        self.walk(node.elements)
        self.walk(deindenting: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftParen)
        self.walk(node.elements)
        self.walk(deindenting: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: FunctionParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.leftParen)
        self.walk(node.parameters)
        self.walk(deindenting: node.rightParen)
        return .skipChildren
    }
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(node.calledExpression)

        if  let left: TokenSyntax = node.leftParen {
            self.walk(indenting: left)
        }

        self.walk(node.arguments)

        if let right: TokenSyntax = node.rightParen {
            self.walk(deindenting: right)
        }

        self.walkIfPresent(node.trailingClosure)
        self.walkIfPresent(node.additionalTrailingClosures)

        return .skipChildren
    }

    override func visit(_ node: IfExprSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.ifKeyword)

        self.walk(node.conditions)
        self.walk(node.body.leftBrace)
        self.walk(node.body.statements)
        self.walk(deindenting: node.body.rightBrace)

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
            self.walk(indenting: codeBlock.leftBrace)
            self.walk(codeBlock.statements)
            self.walk(deindenting: codeBlock.rightBrace)
        }

        return .skipChildren
    }

    override func visit(_ node: ForStmtSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.forKeyword)

        self.walkIfPresent(node.tryKeyword)
        self.walkIfPresent(node.awaitKeyword)
        self.walkIfPresent(node.unsafeKeyword)
        self.walkIfPresent(node.caseKeyword)
        self.walk(node.pattern)
        self.walkIfPresent(node.typeAnnotation)
        self.walk(node.inKeyword)
        self.walk(node.sequence)
        self.walkIfPresent(node.whereClause)
        self.walk(node.body.leftBrace)
        self.walk(node.body.statements)

        self.walk(deindenting: node.body.rightBrace)
        return .skipChildren
    }

    override func visit(_ node: WhileStmtSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.whileKeyword)

        self.walk(node.conditions)
        self.walk(node.body.leftBrace)
        self.walk(node.body.statements)

        self.walk(deindenting: node.body.rightBrace)

        return .skipChildren
    }

    override func visit(_ node: RepeatStmtSyntax) -> SyntaxVisitorContinueKind {
        self.walk(indenting: node.repeatKeyword)

        self.walk(node.body.leftBrace)
        self.walk(node.body.statements)

        self.walk(deindenting: node.body.rightBrace)

        self.walk(node.whileKeyword)
        self.walk(node.condition)

        return .skipChildren
    }

    override func visit(_ node: SwitchCaseSyntax) -> SyntaxVisitorContinueKind {
        self.walkIfPresent(node.attribute)
        switch node.label {
        case .case(let patterns):
            self.walk(indenting: patterns.caseKeyword)
            self.walk(patterns.caseItems)
            self.walk(patterns.colon)
            self.walk(node.statements)

        case .default(let label):
            self.walk(indenting: label.defaultKeyword)
            self.walk(label.colon)
            self.walk(node.statements)
        }
        self.region(start: node.statements.endPosition, delta: -1)
        return .skipChildren
    }
}
extension IndentationCalculator {
    private func walkIfPresent<Node>(_ node: Node?) where Node: SyntaxProtocol {
        if  let node: Node {
            self.walk(node)
        }
    }

    private func walk(indenting left: TokenSyntax) {
        self.walk(left)
        self.region(start: left.endPosition, delta: +1)
    }
    private func walk(deindenting right: TokenSyntax) {
        self.region(start: right.positionAfterSkippingLeadingTrivia, delta: -1)
        self.walk(right)
    }

    private func region(start: AbsolutePosition, delta: Int) {
        self.level += delta
        self.regions.append(.init(start: start.utf8Offset, indent: self.level))
    }
}
