import SwiftSyntax
import SwiftParser

class BlockIndentRewriter: SyntaxRewriter {
    private let length: Int
    private let source: String
    private let sourceTree: SourceFileSyntax
    private var lines: [Substring]

    init(length: Int, source: String) {
        self.length = length
        self.source = source
        self.sourceTree = Parser.parse(source: source)
        self.lines = source.split(separator: "\n", omittingEmptySubsequences: false)
        super.init()
    }

    override func visitAny(_ node: Syntax) -> Syntax? {
        // We only want to format a node if it starts on an overly-long line.
        guard let (_, line) = self.getLine(for: node),
              line.trimmingWhitespace().count > self.length
        else {
            // This node is not on an overly-long line, so continue traversal.
            return super.visitAny(node)
        }

        // Find the column of the first non-whitespace character on the line.
        let column: Int
        if let firstCharIndex = line.firstIndex(where: { !$0.isWhitespace }) {
            column = line.distance(from: line.startIndex, to: firstCharIndex)
        } else {
            column = 0
        }

        let baseIndent: Trivia
        let indentStep: Int = 4

        if self.isInConditonalScope(node) {
            baseIndent = .spaces(column + indentStep) // Align with condition body.
        } else {
            baseIndent = .spaces(column)
        }
        let newIndent: Trivia = baseIndent.appending(Trivia.spaces(indentStep))

        // Apply wrapping to known wrappable node types.
        if let call: FunctionCallExprSyntax = node.as(FunctionCallExprSyntax.self) {
            // Precedence: Always wrap long argument lists before wrapping trailing closures.
            if self.argumentsAreLong(call) {
                return Syntax(self.formatFunctionArguments(call,
                    baseIndent: baseIndent,
                    newIndent: newIndent))
            } else if self.shouldWrapTrailingClosure(call) {
                 return Syntax(self.formatTrailingClosure(call,
                    baseIndent: baseIndent,
                    newIndent: newIndent))
            }
        } else if let decl: FunctionDeclSyntax = node.as(FunctionDeclSyntax.self) {
            return Syntax(self.formatFunctionDecl(decl,
                baseIndent: baseIndent,
                newIndent: newIndent))
        }

        // If this node isn't wrappable, let the superclass handle its children.
        return super.visitAny(node)
    }
}
extension BlockIndentRewriter {
    func format() -> SourceFileSyntax { self.visit(self.sourceTree) }
}
extension BlockIndentRewriter {
    // A helper to get the full line of text for a given syntax node.
    private func getLine(for node: some SyntaxProtocol) -> (number: Int, content: Substring)? {
        let location: SourceLocation = node.startLocation(
            converter: .init(fileName: "", tree: self.sourceTree)
        )
        let lineNumber: Int = location.line - 1
        guard lineNumber < self.lines.count else { return nil }
        return (lineNumber, self.lines[lineNumber])
    }

    private func isInConditonalScope(_ node: Syntax) -> Bool {
        var currentNode: Syntax? = node
        while let parent = currentNode?.parent {
            if let ifStmt: IfExprSyntax = parent.as(IfExprSyntax.self) {
                // Check if the node is within the bounds of the conditions clause.
                if node.position >= ifStmt.conditions.position &&
                   node.endPosition <= ifStmt.conditions.endPosition {
                    return true
                }
            } else if let whileStmt: WhileStmtSyntax = parent.as(WhileStmtSyntax.self) {
                // Check if the node is within the bounds of the conditions clause.
                if node.position >= whileStmt.conditions.position &&
                   node.endPosition <= whileStmt.conditions.endPosition {
                    return true
                }

            }
            currentNode = parent
        }
        return false
    }

    private func argumentsAreLong(_ node: FunctionCallExprSyntax) -> Bool {
        // If there are no arguments, they can't be the problem.
        if node.arguments.isEmpty {
            return false
        }

        // If there's no trailing closure, the arguments are the only thing
        // that could make the line long.
        guard
        let _: ClosureExprSyntax = node.trailingClosure,
        let rightParen: TokenSyntax = node.rightParen else {
            return true
        }

        // If there is a trailing closure, the arguments are only the problem if
        // the line *up to the end of the argument list* is already too long.
        let locationConverter = SourceLocationConverter(fileName: "", tree: self.sourceTree)
        let startLocation = node.startLocation(converter: locationConverter)
        let endOfArgsLocation = rightParen.endLocation(converter: locationConverter)

        // If arguments span multiple lines, they are already wrapped.
        guard startLocation.line == endOfArgsLocation.line else { return false }

        let lengthWithoutClosure = endOfArgsLocation.column - startLocation.column

        return lengthWithoutClosure > self.length
    }

    private func shouldWrapTrailingClosure(_ node: FunctionCallExprSyntax) -> Bool {
        guard let closure = node.trailingClosure else { return false }
        // Only wrap closures that are currently on a single line.
        let startLine = getLine(for: closure.leftBrace)?.number
        let endLine = getLine(for: closure.rightBrace)?.number
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
            // Ensure commas have correct trivia
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

        // 1. Create a new version of the function call with no trailing space on its parenthesis.
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

        // 3. Return the function call with the new, correctly formatted closure.
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
