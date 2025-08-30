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
}