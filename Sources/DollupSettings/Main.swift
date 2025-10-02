import DollupConfig

/// These are the settings Dollup uses to format itself.
@main enum Main: DollupConfiguration {
    public static func configure(_ settings: inout DollupSettings) {
        settings.whitespace {
            $0.width = 96
        }
    }
}
