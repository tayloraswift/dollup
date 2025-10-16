import DollupConfig
import SystemPackage

/// These are the settings Dollup uses to format itself.
@main enum Main: DollupConfiguration {
    public static func configure(file _: FilePath?, settings: inout DollupSettings) {
        settings.check = true
        settings.whitespace {
            $0.width = 96
            $0.braces = .egyptian

            $0.indent.spaces = 4
            $0.indent.ifConfig = false

            $0.formatColonPadding = true
            $0.foldKeywords = true
        }
    }

    public static func report(file: FilePath) {
        print("> reformatted '\(file)'")
    }
}
