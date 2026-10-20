import ArgumentParser
import System_ArgumentParser
import SystemIO

extension DollupCommand where Configuration: DollupDistribution & DollupConfiguration {
    struct FormatAsPlugin {
        @Option(
            name: .customLong("filelist"),
            help: "Path to a newline-delimited list of files to format"
        ) var filelist: FilePath

        // Passed by the generated command plugin for future target- and
        // dependency-scoped rules (#45).
        @Option(
            name: .customLong("target"),
            help: "The name of the target being formatted"
        ) var target: String

        @Option(
            name: .customLong("dependency"),
            help: "A target dependency of the target being formatted"
        ) var dependencies: [String] = []
    }
}
extension DollupCommand.FormatAsPlugin: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(
            commandName: "format-as-plugin",
            shouldDisplay: false
        )
    }

    func run() throws {
        var failed: Bool = false
        try self.filelist.readLines { (line: Substring) in
            guard !line.isEmpty else {
                return
            }
            let file: FilePath = .init(String.init(line))
            do {
                try Configuration.run(on: file)
            } catch {
                print("error formatting file '\(file)': \(error)")
                failed = true
            }
        }
        if  failed {
            throw ExitCode.failure
        }
    }
}
