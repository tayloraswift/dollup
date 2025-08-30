import ArgumentParser
import Foundation
import SystemIO
import RectangleCorrector

struct Dollup: ParsableCommand {
    @Argument(help: "The swift file to format.")
    var file: String

    @Option(name: .shortAndLong, help: "The maximum line length.")
    var maxLength: Int = 96

    mutating func run() throws {
        let url: URL = .init(fileURLWithPath: file)
        let originalContent: String = try .init(contentsOf: url, encoding: .utf8)
        let formattedContent: String = RectangleCorrector.correct(originalContent, maxLength: maxLength)
        try formattedContent.write(to: url, atomically: true, encoding: .utf8)
    }
}

Dollup.main()