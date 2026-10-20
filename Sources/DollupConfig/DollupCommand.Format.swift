import ArgumentParser
import System_ArgumentParser
import SystemIO

extension DollupCommand {
    struct Format {
        @Argument(
            help: "Paths to Swift files or directories to format"
        ) var paths: [FilePath] = []

        @Option(
            name: .customLong("filelist"),
            help: "Path to a newline-delimited list of files to format"
        ) var filelist: FilePath?

        // Passed by the generated command plugin for future target- and
        // dependency-scoped rules (#45).
        @Option(
            name: .customLong("target"),
            help: "The name of the target being formatted"
        ) var target: String?

        @Option(
            name: .customLong("dependency"),
            help: "A target dependency of the target being formatted"
        ) var dependencies: [String] = []
    }
}
extension DollupCommand.Format: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(commandName: "format")
    }

    func validate() throws {
        if  self.paths.isEmpty,
            case nil = self.filelist {
            throw ValidationError.init("no file path given!")
        }
    }

    func run() throws {
        if  let filelist: FilePath = self.filelist {
            try filelist.readLines { (line: Substring) in
                if !line.isEmpty {
                    try Configuration.run(in: .init(String.init(line)))
                }
            }
        }
        for path: FilePath in self.paths {
            try Configuration.run(in: path)
        }
    }
}
