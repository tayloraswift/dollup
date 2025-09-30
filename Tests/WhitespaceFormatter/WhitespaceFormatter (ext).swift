import WhitespaceFormatter

extension WhitespaceFormatter {
    static func reformat(_ source: consuming String, indent: Int = 4, width: Int = 96) -> String {
        var source: String = source
        self.reformat(&source, indent: indent, width: width)
        return source
    }
}
