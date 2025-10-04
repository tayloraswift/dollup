import SwiftSyntax

public enum BraceStyle {
    case allman
    case egyptian
}
extension BraceStyle {
    func moves(_ type: BracketType) -> Bool {
        switch (self, type) {
        case (.egyptian, _): true
        case (.allman, .brace): true
        case (.allman, .square): false
        case (.allman, .parenthesis): false
        case (.allman, .quotes): true
        }
    }

    var before: TriviaPiece {
        switch self {
        case .allman: .newlines(1)
        case .egyptian: .spaces(1)
        }
    }
}
