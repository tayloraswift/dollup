import SwiftSyntax

struct ModifierFolder {
    private let movable: Set<AbsolutePosition>

    init(movable: Set<AbsolutePosition>) {
        self.movable = movable
    }
}
extension ModifierFolder: VerticalFolder {
    var separator: TriviaPiece { .spaces(1) }

    func fold(_ node: TokenSyntax) -> Bool? {
        switch node.tokenKind {
        case .keyword:
            break
        case .atSign:
            break
        default:
            return nil
        }

        if  self.movable.contains(node.positionAfterSkippingLeadingTrivia) {
            return true
        } else {
            return nil
        }
    }
}
