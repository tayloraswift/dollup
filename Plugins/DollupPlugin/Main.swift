import PackagePlugin
import Foundation

@main struct Main: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let package: Package = context.package
        let dollup: PluginContext.Tool = try context.tool(named: "DollupSettings")

        for case let target as SwiftSourceModuleTarget in package.targets {
            print("Formatting '\(target.name)'")

            for file: File in target.sourceFiles(withSuffix: ".swift") {
                let process: Process = try .run(dollup.url, arguments: [file.url.path])
                ;   process.waitUntilExit()

                guard case .exit = process.terminationReason,
                case 0 = process.terminationStatus else {
                    Diagnostics.error(
                        """
                        ❌ dollup failed on file '\(file.url.path)': \
                        \(process.terminationReason), \(process.terminationStatus)
                        """
                    )
                    continue
                }
            }
        }
    }
}
