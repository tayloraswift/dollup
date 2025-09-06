import SwiftSyntax
import SwiftParser

class BlockIndentRewriter: SyntaxRewriter {
    private let length: Int
    private let source: String
    private let sourceTree: SourceFileSyntax
    private var lines: [String]

    init(length: Int, source: String) {
        self.length = length
        self.source = source
        self.sourceTree = Parser.parse(source: source)
        self.lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        super.init()
    }

    override func visitAny(_ node: Syntax) -> Syntax? {
        // Find the outermost wrappable node on a line that is too long.
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

        // Determine the indentation step.
        let indentStep: Int = 4
        let baseIndent: Trivia

        if isInConditonalScope(node) {
            baseIndent = .spaces(column + 4) // Align with condition body.
        } else {
            baseIndent = .spaces(column)
        }

        let newIndent: Trivia = baseIndent.appending(Trivia.spaces(indentStep))

        // Apply wrapping to known wrappable node types.
        if let call: FunctionCallExprSyntax = node.as(FunctionCallExprSyntax.self) {
            return Syntax(self.formatFunctionCall(call,
                baseIndent: baseIndent,
                newIndent: newIndent))
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
    private func getLine(for node: some SyntaxProtocol) -> (number: Int, content: String)? {
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
            if parent.kind == .ifExpr || parent.kind == .whileStmt {
                return true
            }
            currentNode = parent
        }
        return false
    }

    private func formatFunctionCall(
        _ node: FunctionCallExprSyntax,
        baseIndent: Trivia,
        newIndent: Trivia
    ) -> ExprSyntax {

        if let trailingClosure = node.trailingClosure {
             let newLeftBrace = trailingClosure.leftBrace
                 .with(\.leadingTrivia, .space)
             let newRightBrace = trailingClosure.rightBrace
                 .with(\.leadingTrivia, .newline.appending(baseIndent))

             let newStatements = trailingClosure.statements.map {
                 $0.with(\.leadingTrivia, .newline.appending(newIndent))
             }

             let newClosure = trailingClosure
                 .with(\.leftBrace, newLeftBrace)
                 .with(\.statements, .init(newStatements))
                 .with(\.rightBrace, newRightBrace)

             return ExprSyntax(node.with(\.trailingClosure, newClosure))
        }

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

        let newNode: FunctionCallExprSyntax = node
            .with(\.arguments, LabeledExprListSyntax(newArgs))
            .with(\.rightParen, newRightParen)

        return ExprSyntax(newNode)
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

        let newSignature: FunctionSignatureSyntax = node.signature.with(\.parameterClause, newParameterClause)
        return DeclSyntax(node.with(\.signature, newSignature))
    }
}
