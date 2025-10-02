import SystemIO

public protocol DollupConfiguration {
    static func configure(_ settings: inout DollupSettings, file: FilePath) throws
}
extension DollupConfiguration {
    @MainActor public static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            print("no file path given!")
            return
        }

        let file: FilePath = .init(CommandLine.arguments[1])

        var settings: DollupSettings = .init()
        try self.configure(&settings, file: file)

        do {
            var source: String = try file.read()
            settings.whitespace.reformat(&source, check: settings.check)
            try file.overwrite(with: [UInt8].init(source.utf8)[...])
        } catch {
            print("error: \(error)")
            SystemProcess.exit(with: 1)
        }
    }
}
