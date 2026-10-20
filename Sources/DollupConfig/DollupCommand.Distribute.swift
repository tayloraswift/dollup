import ArgumentParser
import SHA2
import System_ArgumentParser
import SystemIO

extension DollupCommand {
    struct Distribute {
        @Option(
            name: .customLong("output"),
            help: "The root directory of the downstream distribution repository"
        ) var output: FilePath.Directory = "."

        @Option(
            name: .customLong("macos"),
            help: "The artifact bundle URL for macOS (arm64)"
        ) var macOS: String

        @Option(
            name: .customLong("linux-x86-64"),
            help: "The artifact bundle URL for Linux (x86_64)"
        ) var linuxX86_64: String

        @Option(
            name: .customLong("linux-aarch64"),
            help: "The artifact bundle URL for Linux (aarch64)"
        ) var linuxAArch64: String
    }
}
extension DollupCommand.Distribute: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(commandName: "distribute")
    }

    func run() throws {
        let archives: (
            macOS: FilePath,
            linuxX86_64: FilePath,
            linuxAArch64: FilePath
        ) = (
            macOS: "macOS-arm64.zip",
            linuxX86_64: "Linux-x86_64.zip",
            linuxAArch64: "Linux-aarch64.zip"
        )
        let checksums: (
            macOS: SHA256,
            linuxX86_64: SHA256,
            linuxAArch64: SHA256
        ) = (
            macOS: .init(hashing: try archives.macOS.read()),
            linuxX86_64: .init(hashing: try archives.linuxX86_64.read()),
            linuxAArch64: .init(hashing: try archives.linuxAArch64.read())
        )

        print("macOS Checksum: \(checksums.macOS)")
        print("Linux Checksum (x86_64): \(checksums.linuxX86_64)")
        print("Linux Checksum (aarch64): \(checksums.linuxAArch64)")

        let pluginDirectory: FilePath.Directory = self.output
            / "Plugins"
            / Configuration.pluginName
        try pluginDirectory.create()

        let manifest: FilePath = self.output / "Package.swift"
        try manifest.overwrite(with: self.manifest(checksums: checksums).utf8)

        let plugin: FilePath = pluginDirectory / "Main.swift"
        try plugin.overwrite(with: self.plugin.utf8)
    }
}
extension DollupCommand.Distribute {
    func manifest(
        checksums: (
            macOS: SHA256,
            linuxX86_64: SHA256,
            linuxAArch64: SHA256
        )
    ) -> String {
        """
        // swift-tools-version: 6.2
        import PackageDescription

        let package: Package = .init(
            name: "\(Configuration.name)",
            products: [
                .plugin(
                    name: "\(Configuration.pluginName)",
                    targets: ["\(Configuration.pluginName)"]
                ),
                .executable(
                    name: "\(Configuration.name)",
                    targets: ["\(Configuration.binaryTargetName)"]
                ),
            ],
            targets: [
                binary,

                .plugin(
                    name: "\(Configuration.pluginName)",
                    capability: .command(
                        intent: .custom(
                            verb: "\(Configuration.verb)",
                            description: "format source files"
                        ),
                        permissions: [.writeToPackageDirectory(reason: "code formatter")],
                    ),
                    dependencies: [
                        .target(name: "\(Configuration.binaryTargetName)"),
                    ]
                ),
            ]
        )

        var binary: Target {
            var url: String {
                #if os(macOS)
                "\(self.macOS)"
                #elseif arch(x86_64)
                "\(self.linuxX86_64)"
                #else
                "\(self.linuxAArch64)"
                #endif
            }
            var checksum: String {
                #if os(macOS)
                "\(checksums.macOS)"
                #elseif arch(x86_64)
                "\(checksums.linuxX86_64)"
                #else
                "\(checksums.linuxAArch64)"
                #endif
            }

            return .binaryTarget(
                name: "\(Configuration.binaryTargetName)",
                url: url,
                checksum: checksum
            )
        }

        """
    }

    var plugin: String {
        #"""
        import Foundation
        import PackagePlugin

        @main struct Main: CommandPlugin {
            func performCommand(context: PluginContext, arguments: [String]) async throws {
                let tool: PluginContext.Tool = try context.tool(named: "\#(Configuration.name)")
                let manifest: URL = context.package.directoryURL.appendingPathComponent(
                    "Package.swift"
                )
                let plugins: URL = context.package.directoryURL.appendingPathComponent(
                    "Plugins"
                )

                try Self.run(tool, arguments: arguments + [manifest.path, plugins.path])

                for case let target as SwiftSourceModuleTarget in context.package.targets {
                    let files: FileList = target.sourceFiles(withSuffix: ".swift")
                    if  files.isEmpty {
                        continue
                    }

                    print("Formatting '\(target.name)'")

                    let filelist: URL = context.pluginWorkDirectoryURL.appendingPathComponent(
                        "\(target.name).filelist"
                    )
                    var list: String = ""
                    for file: File in files {
                        list += "\(file.url.path)\n"
                    }
                    try list.write(to: filelist, atomically: true, encoding: .utf8)

                    var invocation: [String] = arguments
                    invocation += ["--target", target.name]
                    for dependency: any Target in target.recursiveTargetDependencies {
                        invocation += ["--dependency", dependency.name]
                    }
                    invocation += ["--filelist", filelist.path]

                    try Self.run(tool, arguments: invocation)
                }
            }

            private static func run(_ tool: PluginContext.Tool, arguments: [String]) throws {
                let process: Process = try .run(tool.url, arguments: arguments)
                ;   process.waitUntilExit()

                guard case .exit = process.terminationReason,
                case 0 = process.terminationStatus else {
                    Diagnostics.error(
                        """
                        💔 \#(Configuration.name) format failed: \
                        \(process.terminationReason), \(process.terminationStatus)
                        """
                    )
                    return
                }
            }
        }

        """#
    }
}
