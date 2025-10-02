import PackagePlugin
import Foundation

@main struct Main: CommandPlugin {
    // This is the entry point for the plugin.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let package: Package = context.package
        let dollup: PluginContext.Tool = try context.tool(named: "DollupSettings")

        for case let target as SwiftSourceModuleTarget in package.targets {
            print("Formatting '\(target.name)'")

            // Iterate through the source files of the target.
            for file: File in target.sourceFiles(withSuffix: ".swift") {
                let process: Process = try .run(dollup.url, arguments: [file.url.path])
                ;   process.waitUntilExit()

                // Check the termination status to determine success or failure.
                guard case .exit = process.terminationReason,
                case 0 = process.terminationStatus else {
                    Diagnostics.error(
                        """
                        ❌ dollup failed: \
                        \(process.terminationReason), \(process.terminationStatus)
                        """
                    )
                    continue
                }
            }
        }
    }
}
