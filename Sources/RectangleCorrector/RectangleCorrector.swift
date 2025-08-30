import SwiftSyntax
import SwiftParser

public struct RectangleCorrector {
    public static func correct(_ content: String, maxLength: Int) -> String {
        let tree = Parser.parse(source: content)
        let rewriter = RectangleRewriter(maxLength: maxLength)
        let result = rewriter.visit(tree)
        return result.description
    }
}

class RectangleRewriter: SyntaxRewriter {
    let maxLength: Int

    init(maxLength: Int) {
        self.maxLength = maxLength
        super.init()
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let line = node.description.trimmingWhitespace()
        if line.count > maxLength {
            if let trailingClosure = node.trailingClosure {
                let newStatements = trailingClosure.statements.map { stmt in
                    stmt.with(\.leadingTrivia, .newline.appending(Trivia.spaces(4)))
                        .with(\.trailingTrivia, []) // Ensure no trailing trivia on statements
                }

                let newLeftBrace = TokenSyntax(.leftBrace, leadingTrivia: .space, trailingTrivia: [], presence: .present)
                let newRightBrace = TokenSyntax(.rightBrace, leadingTrivia: .newline, trailingTrivia: [], presence: .present)

                let newClosure = ClosureExprSyntax(
                    leftBrace: newLeftBrace,
                    statements: CodeBlockItemListSyntax(newStatements),
                    rightBrace: newRightBrace
                )

                var newNode = node.with(\.trailingClosure, newClosure)
                if let rightParen = newNode.rightParen {
                    newNode = FunctionCallExprSyntax(
                        calledExpression: newNode.calledExpression,
                        leftParen: newNode.leftParen,
                        arguments: newNode.arguments,
                        rightParen: rightParen.with(\.trailingTrivia, []),
                        trailingClosure: newNode.trailingClosure,
                        additionalTrailingClosures: newNode.additionalTrailingClosures
                    )
                }
                return ExprSyntax(newNode)
            }

            var newArgs: [LabeledExprSyntax] = []
            for arg in node.arguments {
                let newArg = arg.with(\.trailingTrivia, .spaces(0))
                newArgs.append(newArg.with(\.leadingTrivia, .newline.appending(Trivia.spaces(4))))
            }
            let newNode = node.with(\.arguments, LabeledExprListSyntax(newArgs))
                                .with(\.rightParen, node.rightParen?.with(\.leadingTrivia, .newline))
            return ExprSyntax(newNode)
        }
        return super.visit(node)
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        let line = node.description.trimmingWhitespace()
        if line.count > maxLength {
            var newParams: [FunctionParameterSyntax] = []
            for param in node.signature.parameterClause.parameters {
                let newParam = param.with(\.trailingTrivia, .spaces(0))
                newParams.append(newParam.with(\.leadingTrivia, .newline.appending(Trivia.spaces(4))))
            }
            let newParameters = FunctionParameterListSyntax(newParams)
            let newParameterClause = node.signature.parameterClause.with(\.parameters, newParameters).with(\.rightParen, node.signature.parameterClause.rightParen.with(\.leadingTrivia, .newline))
            let newSignature = node.signature.with(\.parameterClause, newParameterClause)
            let newNode = node.with(\.signature, newSignature)
            return DeclSyntax(newNode)
        }
        return super.visit(node)
    }
}