import SwiftSyntax
import SwiftParser

class BlockIndentVisitor: SyntaxVisitor {
    private struct LineInfo {
        let length: Int
        let column: Int
    }

    private let length: Int
    private let sourceTree: SourceFileSyntax
    private let lineInfo: [LineInfo]
    private(set) var edits: [Edit] = []

    /// A state variable to track if the visitor is currently inside a conditional statement's
    /// condition clause that requires extra indentation (`if`, `while`).
    private var isInCondition: Bool = false

    init(length: Int, source: String) {
        self.length = length
        self.sourceTree = Parser.parse(source: source)

        // Pre-compute line metrics in a single pass to avoid re-calculation during visitation.
        self.lineInfo = source.split(separator: "\n", omittingEmptySubsequences: false).map { line in
            let trimmedLength = line.trimmingWhitespace().count
            let indentationColumn: Int
            if let firstCharIndex = line.firstIndex(where: { !$0.isWhitespace }) {
                indentationColumn = line.distance(from: line.startIndex, to: firstCharIndex)
            } else {
                indentationColumn = 0
            }
            return LineInfo(length: trimmedLength, column: indentationColumn)
        }

        super.init(viewMode: .sourceAccurate)
    }
    override func visit(_ node: IfExprSyntax) -> SyntaxVisitorContinueKind {
        // Manually visit the conditions with the special indentation flag set.
        isInCondition = true
        walk(node.conditions)
        isInCondition = false

        // Visit the body and any 'else' clause normally.
        walk(node.body)
        if let elseClause = node.elseBody {
            walk(elseClause)
        }

        // We handled the children ourselves.
        return .skipChildren
    }

    override func visit(_ node: WhileStmtSyntax) -> SyntaxVisitorContinueKind {
        // Manually visit the conditions with the special indentation flag set.
        isInCondition = true
        walk(node.conditions)
        isInCondition = false

        // Visit the body normally.
        walk(node.body)

        // We handled the children ourselves.
        return .skipChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        let location = node.startLocation(converter: .init(fileName: "", tree: self.sourceTree))
        let lineNumber = location.line - 1

        // Use the pre-computed line length for a fast check.
        guard lineNumber < self.lineInfo.count,
              self.lineInfo[lineNumber].length > self.length
        else {
            return .visitChildren
        }

        // Find the column of the first non-whitespace character on the line.
        let column = self.lineInfo[lineNumber].column
        let baseIndent: Trivia
        let indentStep: Int = 4

        if self.isInCondition {
            baseIndent = .spaces(column + indentStep) // Align with condition body.
        } else {
            baseIndent = .spaces(column)
        }
        let newIndent: Trivia = baseIndent.appending(Trivia.spaces(indentStep))

        let newText: String
        // Precedence: Always wrap long argument lists before wrapping trailing closures.
        if self.argumentsAreLong(node) {
            newText = "\(self.formatFunctionArguments(node, baseIndent: baseIndent, newIndent: newIndent))"
        } else if self.shouldWrapTrailingClosure(node) {
            newText = "\(self.formatTrailingClosure(node, baseIndent: baseIndent, newIndent: newIndent))"
        } else {
            return .visitChildren
        }

        let edit = Edit(
            start: node.position,
            length: node.totalLength.utf8Length,
            newText: newText
        )
        self.edits.append(edit)

        return .skipChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let location = node.startLocation(converter: .init(fileName: "", tree: self.sourceTree))
        let lineNumber = location.line - 1

        // Use the pre-computed line length for a fast check.
        guard lineNumber < self.lineInfo.count,
              self.lineInfo[lineNumber].length > self.length
        else {
            return .visitChildren
        }

        let column = self.lineInfo[lineNumber].column
        let baseIndent: Trivia = .spaces(column)
        let indentStep: Int = 4
        let newIndent: Trivia = baseIndent.appending(Trivia.spaces(indentStep))

        let newText = "\(self.formatFunctionDecl(node, baseIndent: baseIndent, newIndent: newIndent))"

        let edit = Edit(
            start: node.position,
            length: node.totalLength.utf8Length,
            newText: newText
        )
        self.edits.append(edit)

        return .skipChildren
    }
}

extension BlockIndentVisitor {
    private func argumentsAreLong(_ node: FunctionCallExprSyntax) -> Bool {
        if node.arguments.isEmpty {
            return false
        }
        guard
        let _: ClosureExprSyntax = node.trailingClosure,
        let rightParen: TokenSyntax = node.rightParen else {
            return true
        }
        let locationConverter = SourceLocationConverter(fileName: "", tree: self.sourceTree)
        let startLocation = node.startLocation(converter: locationConverter)
        let endOfArgsLocation = rightParen.endLocation(converter: locationConverter)
        guard startLocation.line == endOfArgsLocation.line else { return false }
        let lengthWithoutClosure = endOfArgsLocation.column - startLocation.column
        return lengthWithoutClosure > self.length
    }

    private func shouldWrapTrailingClosure(_ node: FunctionCallExprSyntax) -> Bool {
        guard let closure = node.trailingClosure else { return false }
        let locationConverter = SourceLocationConverter(fileName: "", tree: self.sourceTree)
        let startLine = closure.leftBrace.startLocation(converter: locationConverter).line
        let endLine = closure.rightBrace.endLocation(converter: locationConverter).line
        return startLine == endLine
    }

    private func formatFunctionArguments(
        _ node: FunctionCallExprSyntax,
        baseIndent: Trivia,
        newIndent: Trivia
    ) -> ExprSyntax {
        var newArgs: [LabeledExprSyntax] = []
        for (index, arg) in node.arguments.enumerated() {
            var newArg = arg.with(\.leadingTrivia, .newline.appending(newIndent))
            if index < node.arguments.count - 1 {
                newArg = newArg.with(\.trailingComma, .commaToken())
            } else {
                newArg = newArg.with(\.trailingComma, nil)
            }
            newArgs.append(newArg)
        }

        let newRightParen: TokenSyntax = node.rightParen?
            .with(\.leadingTrivia, .newline.appending(baseIndent)) ?? .rightParenToken()

        return ExprSyntax(
            node
                .with(\.arguments, LabeledExprListSyntax(newArgs))
                .with(\.rightParen, newRightParen)
        )
    }

    private func formatTrailingClosure(
        _ node: FunctionCallExprSyntax,
        baseIndent: Trivia,
        newIndent: Trivia
    ) -> ExprSyntax {
        guard let trailingClosure = node.trailingClosure else { return ExprSyntax(node) }
        let newCall = node.with(\.rightParen, node.rightParen?.with(\.trailingTrivia, []))
        let newLeftBrace = trailingClosure.leftBrace
            .with(\.leadingTrivia, [.spaces(1)])
        let newStatements = trailingClosure.statements.map {
            $0.with(\.leadingTrivia, .newline.appending(newIndent))
        }
        let newRightBrace = trailingClosure.rightBrace
            .with(\.leadingTrivia, .newline.appending(baseIndent))
        let newClosure = trailingClosure
            .with(\.leftBrace, newLeftBrace)
            .with(\.statements, .init(newStatements))
            .with(\.rightBrace, newRightBrace)
        return ExprSyntax(newCall.with(\.trailingClosure, newClosure))
    }

    private func formatFunctionDecl(
        _ node: FunctionDeclSyntax,
        baseIndent: Trivia,
        newIndent: Trivia
    ) -> DeclSyntax {
        let params: FunctionParameterListSyntax = node.signature.parameterClause.parameters
        var newParams: [FunctionParameterSyntax] = []
        for (index, param) in params.enumerated() {
            var newParam: FunctionParameterSyntax = param
                .with(\.leadingTrivia, .newline.appending(newIndent))

            if index < params.count - 1 {
                newParam = newParam.with(\.trailingComma, .commaToken())
            } else {
                newParam = newParam.with(\.trailingComma, nil)
            }
            newParams.append(newParam)
        }
        let newRightParen: TokenSyntax = node.signature.parameterClause.rightParen
            .with(\.leadingTrivia, .newline.appending(baseIndent))
        let newParameterClause: FunctionParameterClauseSyntax = node.signature.parameterClause
            .with(\.parameters, FunctionParameterListSyntax(newParams))
            .with(\.rightParen, newRightParen)
        let newSignature: FunctionSignatureSyntax = node.signature.with(
            \.parameterClause,
            newParameterClause
        )
        return DeclSyntax(node.with(\.signature, newSignature))
    }
}
