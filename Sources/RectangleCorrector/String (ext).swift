extension String {
    func trimmingWhitespace() -> String {
        var start = startIndex
        while start < endIndex, self[start].isWhitespace {
            start = index(after: start)
        }

        var end = index(before: endIndex)
        while end > start, self[end].isWhitespace {
            end = index(before: end)
        }

        return String(self[start...end])
    }
}
