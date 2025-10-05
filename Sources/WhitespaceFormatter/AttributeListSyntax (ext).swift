import SwiftSyntax

extension AttributeListSyntax {
    var isEmptyOrEndsInVerticalAttribute: Bool {
        if  self.isEmpty {
            return true
        }

        guard case .attribute(let last)? = self.last else {
            return true
        }

        switch last.attributeName.as(IdentifierTypeSyntax.self)?.name.text {
        case "available"?:
            return true
        case "_specialize"?:
            return true
        default:
            return false
        }
    }
}
