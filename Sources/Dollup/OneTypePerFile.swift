import SwiftDiagnostics
import SwiftParser
import SwiftSyntax
import SystemIO

public enum OneTypePerFile {
    public static func check(
        source: String,
        in file: FilePath
    ) -> [Diagnostic] {
        let tree: SourceFileSyntax = Parser.parse(source: source)
        return self.check(tree: tree, in: file)
    }

    public static func check(
        tree: SourceFileSyntax,
        in file: FilePath
    ) -> [Diagnostic] {
        var checker: Checker = .init(tree: tree, file: file)
        return checker.check()
    }

    public static func diagnose(
        source: String,
        in file: FilePath
    ) -> FileDiagnostics? {
        let tree: SourceFileSyntax = Parser.parse(source: source)
        let diags: [Diagnostic] = self.check(tree: tree, in: file)
        guard !diags.isEmpty else {
            return nil
        }
        let annotated: String = DiagnosticsFormatter.annotatedSource(
            tree: tree,
            diags: diags
        )
        return .init(file: file, message: annotated)
    }
}
