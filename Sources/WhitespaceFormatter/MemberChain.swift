import SwiftSyntax

struct MemberChain {
    let base: ExprSyntax
    let flattened: [Link]
}
extension MemberChain {
    init?(unrolling node: borrowing some ExprSyntaxProtocol) {
        var links: Links = .init()
        let base: ExprSyntax = links.unroll(node)
        if  links.list.isEmpty {
            return nil
        }
        self.init(base: base, flattened: links.list)
    }
}
