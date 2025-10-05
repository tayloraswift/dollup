enum LinebreakTier: Comparable {
    case block
    case decorator
    case inline
    case angles
    case `subscript`
    case typeSugar
    case string
}
extension LinebreakTier {
    var direction: Direction {
        switch self {
        case .block: .rtl
        case .decorator: .rtl
        case .inline: .ltr
        case .angles: .ltr
        case .subscript: .rtl
        case .typeSugar: .ltr
        case .string: .ltr
        }
    }
}
