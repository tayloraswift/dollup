import ArgumentParser
import WhitespaceFormatter
import Dollup
import SystemIO
import System_ArgumentParser

@main struct Dollup {
    @Argument(help: "The swift file to format.")
    var file: FilePath

    @Option(
        name: [.customShort("I"), .customLong("indent")],
        help: "The number of spaces to use for indentation"
    )
    var indent: Int = 4

    @Option(
        name: [.customShort("L"), .customLong("line-length")],
        help: "The line length guide to apply"
    )
    var width: Int = 96

    @Option(
        name: [.customShort("g"), .customLong("ignore")],
        help: """
        A list of file patterns to ignore \
        (e.g. 'generated' to ignore all '*.generated.swift' files)
        """,
    )
    var ignore: [String] = []

    @Flag(
        name: [.customShort("y"), .customLong("disable-integrity-check")],
        help: """
        Skip the integrity check that ensures the reformatted source is semantically \
        equivalent to the original
        """
    )
    var checkDisabled: Bool = false

    // TODO: need better way to organize these options
    @Flag(
        name: [.customLong("indent-if-config")],
        help: """
        Indent the contents of #if ... #else ... #endif blocks
        """
    )
    var _indentIfConfig: Bool = false
}
extension Dollup: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(
            commandName: "dollup",
        )
    }

    func run() throws {
        let status: FileStatus = try .status(of: self.file)
        if  status.is(.regular) {
            try self.run(on: self.file)
            return
        }

        guard status.is(.directory) else {
            throw """
            path '\(self.file)' is not a file or directory
            """ as DollupError
        }

        let ignore: [[Substring]] = self.ignore.map { $0.split(separator: ".") }

        try self.file.directory.walk {
            let path: FilePath = $0 / $1

            let status: FileStatus = try .status(of: path)
            if status.is(.directory) {
                return true
            }

            format:
            if  status.is(.regular),
                case "swift" = $1.extension {

                let prefix: [Substring] = $1.stem.split(separator: ".")
                for pattern: [Substring] in ignore
                    where prefix.suffix(pattern.count) == pattern {
                    break format
                }

                print("formatting '\($1)'")
                try self.run(on: path)
            }

            return false
        }
    }
}
extension Dollup {
    private func run(on file: FilePath) throws {
        var source: String = try file.read()
        let formatter: WhitespaceFormatter = try .init {
            $0.indent.ifConfig = self._indentIfConfig
            $0.indent.spaces = self.indent

            $0.width = self.width
        }

        formatter.reformat(&source, check: !self.checkDisabled)

        try file.overwrite(with: [UInt8].init(source.utf8)[...])
    }
}
