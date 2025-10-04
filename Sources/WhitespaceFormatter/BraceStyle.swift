import SwiftSyntax

public enum BraceStyle {
    case allman
    case `k&r`
}
extension BraceStyle {
    func moves(_ type: BracketType) -> Bool {
        switch (self, type) {
        case (.`k&r`, _): true
        case (.allman, .brace): true
        case (.allman, .square): false
        case (.allman, .parenthesis): false
        case (.allman, .quotes): true
        }
    }

    var before: TriviaPiece {
        switch self {
        case .allman: .newlines(1)
        case .`k&r`: .spaces(1)
        }
    }
}
