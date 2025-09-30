import ArgumentParser
import SystemIO
import System_ArgumentParser
import BlockIndentFormatter

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

    @Flag(
        name: [.customShort("y"), .customLong("disable-integrity-check")],
        help: """
        Skip the integrity check that ensures the reformatted source is semantically \
        equivalent to the original
        """
    )
    var checkDisabled: Bool = false
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

        try self.file.directory.walk {
            let path: FilePath = $0 / $1

            let status: FileStatus = try .status(of: path)
            if  status.is(.regular) {
                print("formatting '\($1)'")
                try self.run(on: path)
            } else if status.is(.directory) {
                return true
            }
            return false
        }
    }
}
extension Dollup {
    private func run(on file: FilePath) throws {
        var source: String = try file.read()
        BlockIndentFormatter.reformat(
            &source,
            indent: self.indent,
            width: self.width,
            check: !self.checkDisabled
        )
        try file.overwrite(with: [UInt8].init(source.utf8)[...])
    }
}
