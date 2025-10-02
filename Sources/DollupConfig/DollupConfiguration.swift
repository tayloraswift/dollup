import SystemIO

public protocol DollupConfiguration {
    static func configure(_ settings: inout DollupSettings, file: FilePath?) throws
}
extension DollupConfiguration {
    public static func format(_ source: consuming String, id: FilePath? = nil) throws -> String {
        var settings: DollupSettings = .init()
        try self.configure(&settings, file: id)
        var source: String = source
        settings.whitespace.reformat(&source, check: settings.check)
        return source
    }
}
extension DollupConfiguration {
    @MainActor public static func main() {
        guard CommandLine.arguments.count == 2 else {
            print("no file path given!")
            return
        }

        let file: FilePath = .init(CommandLine.arguments[1])

        do {
            let before: String = try file.read()
            let after: String = try self.format(before, id: file)
            if  after.utf8.elementsEqual(before.utf8) {
                return
            }
            try file.overwrite(with: [UInt8].init(after.utf8)[...])
        } catch {
            print("error: \(error)")
            SystemProcess.exit(with: 1)
        }
    }
}
