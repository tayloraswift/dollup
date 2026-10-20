import ArgumentParser
import System_ArgumentParser
import SystemIO

extension DollupCommand where Configuration: DollupConfiguration {
    struct Format {
        @Argument(
            help: "Paths to Swift files or directories to format"
        ) var paths: [FilePath]
    }
}
extension DollupCommand.Format: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(commandName: "format")
    }

    func run() throws {
        var failed: Bool = false
        for path: FilePath in self.paths {
            do {
                try Configuration.run(in: path)
            } catch {
                print("error formatting file '\(path)': \(error)")
                failed = true
            }
        }
        if  failed {
            throw ExitCode.failure
        }
    }
}
