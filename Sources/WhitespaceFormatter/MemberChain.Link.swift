import SwiftSyntax

extension MemberChain {
    enum Link {
        case property(TokenSyntax, DeclReferenceExprSyntax)
        case function(TokenSyntax, DeclReferenceExprSyntax, FunctionCallExprSyntax)
        case `subscript`(TokenSyntax, DeclReferenceExprSyntax, SubscriptCallExprSyntax)
        case postfixIfConfig(PostfixIfConfigExprSyntax)
        case postfixOperator(TokenSyntax)
    }
}
extension MemberChain.Link {
    var period: TokenSyntax? {
        switch self {
        case .property(let period, _): period
        case .function(let period, _, _): period
        case .subscript(let period, _, _): period
        case .postfixIfConfig: nil
        case .postfixOperator: nil
        }
    }

    var endPositionBeforeTrailingTrivia: AbsolutePosition {
        switch self {
        case .property(_, let last):
            return last.endPositionBeforeTrailingTrivia
        case .function(_, _, let last):
            return last.additionalTrailingClosures.endPositionBeforeTrailingTrivia
        case .subscript(_, _, let last):
            return last.endPositionBeforeTrailingTrivia
        case .postfixIfConfig(let last):
            return last.endPositionBeforeTrailingTrivia
        case .postfixOperator(let last):
            return last.endPositionBeforeTrailingTrivia
        }
    }
}
