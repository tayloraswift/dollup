import SwiftSyntax

extension MemberChain {
    struct Links {
        private(set) var list: [Link]
        init() {
            self.list = []
        }
    }
}
extension MemberChain.Links {
    mutating func unroll(_ node: some ExprSyntaxProtocol) -> ExprSyntax {
        defer {
            self.list.reverse()
        }

        var base: ExprSyntax = ExprSyntax.init(node)
        var next: ExprSyntax? = base
        while let node: ExprSyntax = next {
            base = node
            if  let node: OptionalChainingExprSyntax = node.as(
                    OptionalChainingExprSyntax.self
                ) {
                next = node.expression
                self.list.append(.postfixOperator(node.questionMark))
            } else if
                let node: ForceUnwrapExprSyntax = node.as(ForceUnwrapExprSyntax.self) {
                next = node.expression
                self.list.append(.postfixOperator(node.exclamationMark))
            } else if
                let node: PostfixOperatorExprSyntax = node.as(PostfixOperatorExprSyntax.self) {
                next = node.expression
                self.list.append(.postfixOperator(node.operator))
            } else if
                let call: SubscriptCallExprSyntax = node.as(SubscriptCallExprSyntax.self) {
                if  let functor: MemberAccessExprSyntax = call.calledExpression.as(
                        MemberAccessExprSyntax.self
                    ),
                    let base: ExprSyntax = functor.base {
                    self.list.append(.subscript(functor.period, functor.declName, call))
                    next = base
                } else {
                    next = nil
                }
            } else if
                let call: FunctionCallExprSyntax = node.as(FunctionCallExprSyntax.self) {
                if  let functor: MemberAccessExprSyntax = call.calledExpression.as(
                        MemberAccessExprSyntax.self
                    ),
                    let base: ExprSyntax = functor.base {
                    self.list.append(.function(functor.period, functor.declName, call))
                    next = base
                } else {
                    next = nil
                }
            } else if
                let call: MemberAccessExprSyntax = node.as(MemberAccessExprSyntax.self) {
                if  let base: ExprSyntax = call.base {
                    self.list.append(.property(call.period, call.declName))
                    next = base
                } else {
                    next = nil
                }
            } else if
                let expression: PostfixIfConfigExprSyntax = node.as(
                    PostfixIfConfigExprSyntax.self
                ) {
                if  let base: ExprSyntax = expression.base {
                    self.list.append(.postfixIfConfig(expression))
                    next = base
                } else {
                    next = nil
                }
            } else {
                next = nil
            }
        }

        return base
    }
}
