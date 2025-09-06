import ArgumentParser
import SystemIO
import System_ArgumentParser
import BlockIndentFormatter

struct Dollup: ParsableCommand {
    @Argument(help: "The swift file to format.")
    var file: FilePath

    @Option(name: .shortAndLong, help: "The maximum line length.")
    var length: Int = 96

    mutating func run() throws {
        let original: String = try self.file.read()
        let formatted: String = BlockIndentFormatter.correct(original, length: length)
        try self.file.overwrite(with: [UInt8].init(formatted.utf8)[...])
    }
}
