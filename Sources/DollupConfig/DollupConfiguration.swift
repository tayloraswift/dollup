import Dollup
import SystemIO

public protocol DollupConfiguration {
    static func configure(file: FilePath?, settings: inout DollupSettings) throws
    static func filter(file: FilePath) throws -> Bool
    static func report(file: FilePath) throws
}
extension DollupConfiguration {
    public static func filter(file _: FilePath) throws -> Bool { true }
    public static func report(file _: FilePath) throws {}
}
extension DollupConfiguration {
    public static func format(
        _ source: String,
        id: FilePath? = nil
    ) throws -> String? {
        var settings: DollupSettings = .init()
        try self.configure(file: id, settings: &settings)
        var after: String = source

        settings.whitespace.reformat(&after, check: settings.check)

        if !after.utf8.elementsEqual(source.utf8) {
            return after
        } else {
            return nil
        }
    }
}
extension DollupConfiguration {
    @MainActor public static func main() {
        guard CommandLine.arguments.count == 2 else {
            print("no file path given!")
            SystemProcess.exit(with: 1)
        }

        let path: FilePath = .init(CommandLine.arguments[1])

        do {
            try self.run(in: path)
        } catch {
            print("error formatting file '\(path)': \(error)")
            SystemProcess.exit(with: 1)
        }
    }
}
extension DollupConfiguration {
    public static func run(in path: FilePath) throws {
        let status: FileStatus = try .status(of: path)
        if  status.is(.regular) {
            try self.run(on: path)
            return
        }

        guard status.is(.directory) else {
            throw """
            path '\(path)' is not a file or directory
            """ as DollupError
        }

        try path.directory.walk {
            let path: FilePath = $0 / $1

            let status: FileStatus = try .status(of: path)
            if status.is(.directory) {
                return true
            }

            format:
            if  status.is(.regular),
                case "swift" = $1.extension {
                try self.run(on: path)
            }

            return false
        }
    }

    public static func run(on file: FilePath) throws {
        if  try self.filter(file: file),
            let formatted: String = try self.format(try file.read(), id: file) {
            try self.report(file: file)
            try file.overwrite(with: [UInt8].init(formatted.utf8)[...])
        }
    }
}
