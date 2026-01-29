import SwiftSyntax

extension MemberChain {
    enum Link {
        case property(TokenSyntax, DeclReferenceExprSyntax)
        case function(TokenSyntax, DeclReferenceExprSyntax, FunctionCallExprSyntax)
        case `subscript`(TokenSyntax, DeclReferenceExprSyntax, SubscriptCallExprSyntax)
        case postfixIfConfig(IfConfigDeclSyntax)
    }
}
extension MemberChain.Link {
    var period: TokenSyntax? {
        switch self {
        case .property(let period, _): period
        case .function(let period, _, _): period
        case .subscript(let period, _, _): period
        case .postfixIfConfig: nil
        }
    }
}
