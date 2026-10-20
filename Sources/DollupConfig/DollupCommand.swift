import ArgumentParser

struct DollupCommand<Configuration: DollupConfiguration>: ParsableCommand {
    static var configuration: CommandConfiguration {
        .init(
            commandName: Configuration.name,
            subcommands: [
                Format.self,
                Bundle.self,
                Distribute.self,
            ],
            defaultSubcommand: Format.self
        )
    }
}
