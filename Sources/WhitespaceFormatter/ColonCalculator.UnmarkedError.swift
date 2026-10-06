import SwiftDiagnostics
import SwiftSyntax

extension ColonCalculator {
    struct UnmarkedError: Error {
        let token: TokenSyntax

        init(token: TokenSyntax) {
            self.token = token
        }
    }
}
extension ColonCalculator.UnmarkedError: CustomStringConvertible {
    var description: String {
        let diagnostic: Diagnostic = .init(
            node: self.token,
            position: self.token.positionAfterSkippingLeadingTrivia,
            message: Message.init(
                message: """
                unexpected colon, syntax tree might be malformed
                """
            )
        )
        return DiagnosticsFormatter.annotatedSource(tree: self.token.root, diags: [diagnostic])
    }
}
