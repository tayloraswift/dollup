struct LinebreakContext {
    var tier: LinebreakTier?
    var breaks: [Linebreak]

    init() {
        self.tier = nil
        self.breaks = []
    }
}
