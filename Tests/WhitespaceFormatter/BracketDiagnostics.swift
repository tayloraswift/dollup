import Testing
import WhitespaceFormatter

@Suite struct BracketDiagnostics {
    @Test static func MismatchedBrace() {
        let source: String = """
        func example() {
            print("hello"
        }
        """

        let message: String = self.diagnose(source)

        let expected: String = """
        1 | func example() {
        2 |     print("hello"
        3 | }
          | `- error: mismatched delimiter, expected 'parenthesis', got 'brace'
        4 |\u{20}

        """

        #expect(message == expected)
    }

    @Test static func MismatchedParenthesis() {
        let source: String = """
        func example() {
            let x: Int = 42
        )
        """

        let message: String = self.diagnose(source)

        let expected: String = """
        1 | func example() {
        2 |     let x: Int = 42
        3 |     )
          |     `- error: mismatched delimiter, expected 'brace', got 'parenthesis'
        4 |\u{20}

        """

        #expect(message == expected)
    }

    @Test static func MismatchedSquareBracket() {
        let source: String = """
        func example() {
            let items: (Int, Int) = (1, 2]
        }
        """

        let message: String = self.diagnose(source)

        let expected: String = """
        1 | func example() {
        2 |     let items: (Int, Int) = (1, 2]
          |                                  `- error: \
        mismatched delimiter, expected 'parenthesis', got 'square'
        3 | }
        4 |\u{20}

        """

        #expect(message == expected)
    }
}
extension BracketDiagnostics {
    private static func diagnose(_ source: consuming String) -> String {
        do {
            _ = try WhitespaceFormatter.reformat(source)
            Issue.record("expected delimiter mismatch error was not thrown")
            return ""
        } catch {
            return String.init(describing: error)
        }
    }
}
