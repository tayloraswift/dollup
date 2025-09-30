extension String {
    func insert(linebreaks: [Linebreak]) -> String {
        // Most linebreaking transformers do not emit linebreaks in source order
        let linebreaks: [Linebreak] = linebreaks.sorted { $0.index < $1.index }

        var linebroken: String = ""
        var i: String.Index = self.startIndex
        for j: Linebreak in linebreaks {
            linebroken += self[i ..< j.index]
            linebroken.append("\(j.type)")
            i = j.index
        }
        if  i < self.endIndex {
            linebroken += self[i ..< self.endIndex]
        }
        return linebroken
    }
}
