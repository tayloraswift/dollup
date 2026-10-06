import SwiftDiagnostics
import SwiftSyntax

extension BracketCalculator {
    struct MismatchError: Error {
        let expected: BracketType
        let found: BracketType
        let token: TokenSyntax

        init(expected: BracketType, found: BracketType, token: TokenSyntax) {
            self.expected = expected
            self.found = found
            self.token = token
        }
    }
}
extension BracketCalculator.MismatchError: CustomStringConvertible {
    var description: String {
        let diagnostic: Diagnostic = .init(
            node: self.token,
            position: self.token.positionAfterSkippingLeadingTrivia,
            message: Message.init(
                message: """
                mismatched delimiter, expected '\(self.expected)', got '\(self.found)'
                """
            )
        )
        return DiagnosticsFormatter.annotatedSource(tree: self.token.root, diags: [diagnostic])
    }
}
