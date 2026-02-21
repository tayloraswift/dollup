import SwiftSyntax

struct TokenFolder {
    private let movable: [AbsolutePosition: Bool]

    init(movable: [AbsolutePosition: Bool]) {
        self.movable = movable
    }
}
extension TokenFolder: VerticalFolder {
    var separator: TriviaPiece { .spaces(1) }
    func fold(_ node: TokenSyntax) -> Bool? {
        self.movable[node.positionAfterSkippingLeadingTrivia]
    }
}
