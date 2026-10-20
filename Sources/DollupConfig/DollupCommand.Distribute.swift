import ArgumentParser
import System_ArgumentParser
import SystemIO

extension DollupCommand {
    struct Distribute {
        @Option(
            name: .customLong("output"),
            help: "The root directory of the downstream distribution repository"
        ) var output: FilePath.Directory = "."

        @Option(
            name: .customLong("url-macos"),
            help: "The artifact bundle URL for macOS (arm64)"
        ) var urlMacOS: String

        @Option(
            name: .customLong("url-linux-x86-64"),
            help: "The artifact bundle URL for Linux (x86_64)"
        ) var urlLinuxX86_64: String

        @Option(
            name: .customLong("url-linux-aarch64"),
            help: "The artifact bundle URL for Linux (aarch64)"
        ) var urlLinuxAArch64: String

        @Option(
            name: .customLong("checksum-macos"),
            help: "The artifact bundle checksum for macOS (arm64)"
        ) var checksumMacOS: String

        @Option(
            name: .customLong("checksum-linux-x86-64"),
            help: "The artifact bundle checksum for Linux (x86_64)"
        ) var checksumLinuxX86_64: String

        @Option(
            name: .customLong("checksum-linux-aarch64"),
            help: "The artifact bundle checksum for Linux (aarch64)"
        ) var checksumLinuxAArch64: String
    }
}
extension DollupCommand.Distribute: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(commandName: "distribute")
    }

    func run() throws {
        let pluginDirectory: FilePath.Directory = self.output
            / "Plugins"
            / Configuration.pluginName
        try pluginDirectory.create()

        let manifest: FilePath = self.output / "Package.swift"
        try manifest.overwrite(with: self.manifest.utf8)

        let plugin: FilePath = pluginDirectory / "Main.swift"
        try plugin.overwrite(with: self.plugin.utf8)
    }
}
extension DollupCommand.Distribute {
    var manifest: String {
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
                "\(self.urlMacOS)"
                #elseif arch(x86_64)
                "\(self.urlLinuxX86_64)"
                #else
                "\(self.urlLinuxAArch64)"
                #endif
            }
            var checksum: String {
                #if os(macOS)
                "\(self.checksumMacOS)"
                #elseif arch(x86_64)
                "\(self.checksumLinuxX86_64)"
                #else
                "\(self.checksumLinuxAArch64)"
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
