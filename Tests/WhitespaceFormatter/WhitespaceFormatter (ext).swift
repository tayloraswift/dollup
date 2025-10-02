import WhitespaceFormatter

extension WhitespaceFormatter {
    static func reindent(_ source: String, by indent: Int) throws -> String {
        let formatter: Self = .init {
            $0.indent.ifConfig = true
            $0.indent.spaces = indent
        }
        return formatter.reindent(source)
    }
    static func reformat(
        _ source: consuming String,
        indent: Int = 4,
        width: Int = 96
    ) throws -> String {
        let formatter: Self = .init {
            $0.indent.ifConfig = false
            $0.indent.spaces = indent

            $0.width = width
        }
        var source: String = source
        formatter.reformat(&source, check: true)
        return source
    }
}
