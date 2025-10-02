import DollupConfig
import SystemPackage

/// These are the settings Dollup uses to format itself.
@main enum Main: DollupConfiguration {
    public static func configure(_ settings: inout DollupSettings, file: FilePath?) {
        settings.whitespace {
            $0.width = 96
        }

        if  let file: FilePath {
            print("> '\(file)'")
        }
    }
}
