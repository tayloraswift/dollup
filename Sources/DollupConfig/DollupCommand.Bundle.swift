import ArgumentParser
import System_ArgumentParser
import SystemIO

extension DollupCommand {
    struct Bundle {
        @Argument(
            help: "The executable binary to package into the artifact bundle"
        ) var executable: FilePath

        @Option(
            name: .customLong("version"),
            help: "The version string for the artifact bundle"
        ) var version: String

        @Option(
            name: .customLong("output"),
            help: "The output directory for the artifact bundle"
        ) var output: FilePath.Directory?
    }
}
extension DollupCommand.Bundle: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(commandName: "bundle")
    }

    func run() throws {
        let bundle: FilePath.Directory = self.output
            ?? "\(Configuration.name).artifactbundle"
        let destination: FilePath.Directory = bundle / Self.arch
        try destination.create()

        let binary: FilePath = destination / Configuration.name
        try binary.remove(force: true)
        try binary.overwrite(
            with: try self.executable.read()[...],
            permissions: (.rwx, .rx, .rx)
        )

        let info: FilePath = bundle / "info.json"
        try info.overwrite(with: self.info.utf8)
    }
}
extension DollupCommand.Bundle {
    static var arch: String {
        #if os(macOS)
        #if arch(arm64)
        "arm64"
        #elseif arch(x86_64)
        "x86_64"
        #endif
        #elseif os(Linux)
        #if arch(arm64)
        "aarch64"
        #elseif arch(x86_64)
        "x86_64"
        #endif
        #endif
    }

    static var triple: String {
        #if os(macOS)
        "\(Self.arch)-apple-macosx"
        #elseif os(Linux)
        "\(Self.arch)-unknown-linux-gnu"
        #endif
    }

    var info: String {
        """
        {
            "schemaVersion": "1.1",
            "artifacts": {
                "\(Configuration.name)": {
                    "type": "executable",
                    "version": "\(self.version)",
                    "variants": [
                        {
                            "path": "\(Self.arch)/\(Configuration.name)",
                            "supportedTriples": ["\(Self.triple)"]
                        }
                    ]
                }
            }
        }

        """
    }
}
