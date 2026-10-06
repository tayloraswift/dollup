import SwiftDiagnostics
import SwiftSyntax

extension BracketCalculator {
    struct MismatchError: Error {
        let expected: BracketType
        let found: BracketType
        let token: TokenSyntax
    }
}
extension BracketCalculator.MismatchError {
    var description: String {
        let diagnostic: Diagnostic = .init(
            node: token,
            position: token.positionAfterSkippingLeadingTrivia,
            message: Message.init(
                message: """
                mismatched delimiter, expected '\(self.expected)', got '\(self.found)'
                """
            )
        )
        return DiagnosticsFormatter.annotatedSource(tree: token.root, diags: [diagnostic])
    }
}
