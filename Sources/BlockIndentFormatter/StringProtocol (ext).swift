extension StringProtocol {
    func trimmingWhitespace() -> SubSequence {
        var start: Index = self.startIndex

        while start < self.endIndex, self[start].isWhitespace {
            start = self.index(after: start)
        }

        return self[start...].trimmingWhitespaceFromEnd()
    }

    func trimmingWhitespaceFromEnd() -> SubSequence {
        guard self.startIndex < self.endIndex else {
            return self[...]
        }

        var end: Index = self.index(before: self.endIndex)

        while end >= self.startIndex, self[end].isWhitespace {
            end = self.index(before: end)
        }

        return self[...end]
    }
}
