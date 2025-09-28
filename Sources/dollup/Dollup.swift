import ArgumentParser
import SystemIO
import System_ArgumentParser
import BlockIndentFormatter

@main struct Dollup: ParsableCommand {
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

    mutating func run() throws {
        var source: String = try self.file.read()
        BlockIndentFormatter.reformat(
            &source,
            indent: self.indent,
            width: self.width,
            check: !self.checkDisabled
        )
        try self.file.overwrite(with: [UInt8].init(source.utf8)[...])
    }
}
