import SwiftDiagnostics

extension ColonCalculator.UnmarkedError {
    struct Message {
        let message: String

        init(message: String) {
            self.message = message
        }
    }
}
extension ColonCalculator.UnmarkedError.Message: DiagnosticMessage {
    var diagnosticID: MessageID {
        .init(domain: "ColonCalculator", id: "Unmarked")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
