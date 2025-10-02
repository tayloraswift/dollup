import SystemIO

public protocol DollupConfiguration {
    static func configure(_ settings: inout DollupSettings, file: FilePath?) throws
}
extension DollupConfiguration {
    public static func format(_ source: inout String, id: FilePath? = nil) throws {
        var settings: DollupSettings = .init()
        try self.configure(&settings, file: id)
        settings.whitespace.reformat(&source, check: settings.check)
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
            var source: String = try file.read()
            try self.format(&source, id: file)
            try file.overwrite(with: [UInt8].init(source.utf8)[...])
        } catch {
            print("error: \(error)")
            SystemProcess.exit(with: 1)
        }
    }
}
