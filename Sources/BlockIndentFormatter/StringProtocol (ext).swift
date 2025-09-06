extension StringProtocol {
    func trimmingWhitespace() -> SubSequence {
        var start: Index = self.startIndex

        while start < endIndex, self[start].isWhitespace {
            start = index(after: start)
        }
        guard start < endIndex else {
            // The string is all whitespace.
            return self[start ..< endIndex]
        }

        var end: Index = self.index(before: self.endIndex)
        while end > start, self[end].isWhitespace {
            end = index(before: end)
        }

        return self[start ... end]
    }
}
