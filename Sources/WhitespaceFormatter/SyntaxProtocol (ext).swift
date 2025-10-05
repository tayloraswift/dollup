import SwiftSyntax

extension SyntaxProtocol {
    func containsInteriorNewlines(between delimiter: (TokenSyntax, TokenSyntax)) -> Bool {
        let tokens: TokenSequence = self.tokens(viewMode: .sourceAccurate)
        for token: TokenSyntax in tokens {
            // only leading trivia can ever contain newlines
            for case .newlines in token.leadingTrivia {
                return true
            }
        }
        for case .newlines in delimiter.1.leadingTrivia {
            return true
        }
        return false
    }
    var containsInteriorNewlines: Bool {
        let tokens: TokenSequence = self.tokens(viewMode: .sourceAccurate)
        for token: TokenSyntax in tokens.dropFirst() {
            // only leading trivia can ever contain newlines
            for case .newlines in token.leadingTrivia {
                return true
            }
        }
        return false
    }
    var lacksPrecedingNewline: Bool {
        for case .newlines in self.leadingTrivia {
            return false
        }
        return true
    }

    var withoutTrailingSpaces: Self {
        self.with(\.trailingTrivia, self.trailingTrivia.withoutTrailingSpaces)
    }
}
