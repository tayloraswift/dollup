import ArgumentParser

struct DollupCommand<Configuration: DollupConfiguration> {
}
extension DollupCommand: Decodable {
}
extension DollupCommand: ParsableArguments {
}
extension DollupCommand: ParsableCommand where Configuration: DollupDistribution {
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
