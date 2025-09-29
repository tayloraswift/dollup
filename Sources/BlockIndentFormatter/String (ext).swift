extension String {
    func insert(linebreaks: [Linebreak]) -> String {
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
