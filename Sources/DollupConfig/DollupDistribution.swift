public protocol DollupDistribution: DollupConfiguration {
    /// The name of the executable and downstream package.
    static var name: String { get }
    /// The SwiftPM command plugin verb used to invoke the formatter.
    static var verb: String { get }
    /// The name of the generated SwiftPM command plugin product and target.
    static var plugin: String { get }
    /// The name of the generated SwiftPM binary target.
    static var binary: String { get }
}
extension DollupDistribution {
    public static var name: String { "dollup" }
    public static var verb: String { Self.name }
    public static var plugin: String { "DollupPlugin" }
    public static var binary: String { "DollupBinary" }
}
extension DollupDistribution {
    @MainActor public static func main() {
        DollupCommand<Self>.main()
    }
}
