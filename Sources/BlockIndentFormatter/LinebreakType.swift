enum LinebreakType {
    case newline
    case quotesAfter
    case quotesBefore
}
extension LinebreakType: CustomStringConvertible {
    var description: String {
        switch self {
        case .newline: "\n"
        case .quotesAfter: "\n\"\""
        case .quotesBefore: "\"\"\n"
        }
    }
}
