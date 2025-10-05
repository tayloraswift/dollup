import Testing
import WhitespaceFormatter

@Suite struct ColonSpacingTests {
    @Test static func DictionaryLiterals() throws {
        let input: String = """
        let a: [String:Int] = [:]
        """
        let expected: String = """
        let a: [String: Int] = [:]
        """

        #expect(self.format(input) == expected + "\n")
    }
}
extension ColonSpacingTests {
    private static func format(_ input: consuming String) -> String {
        let formatter: WhitespaceFormatter = .init { $0.spacesAfterColons = true }
        var input: String = input
        formatter.reformat(&input, check: true)
        return input
    }
}
