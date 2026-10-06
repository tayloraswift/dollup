import SwiftDiagnostics

extension BracketCalculator.MismatchError {
    struct Message {
        let message: String
    }
}
extension BracketCalculator.MismatchError.Message: DiagnosticMessage {
    var diagnosticID: MessageID {
        .init(domain: "BracketCalculator", id: "Mismatch")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
