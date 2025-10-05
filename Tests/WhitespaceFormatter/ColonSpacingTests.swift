import Testing
import WhitespaceFormatter

@Suite struct ColonSpacingTests {
    @Test static func DictionaryLiterals() throws {
        let input: String = """
        let a: [String:Int] = [:]
        let b: [String :Int] = [
            "x":1,
            "y" : 2,
            "z"  :   3
        ]
        """
        let expected: String = """
        let a: [String: Int] = [:]
        let b: [String: Int] = [
            "x": 1,
            "y": 2,
            "z":   3
        ]
        """

        #expect(self.format(input) == expected + "\n")
    }
    @Test static func SwitchCases() throws {
        let input: String = """
        switch value {
        case .foo : break
        case .bar: break
        case .baz  :break
        default :   break
        }
        """
        let expected: String = """
        switch value {
        case .foo: break
        case .bar: break
        case .baz: break
        default:   break
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
    @Test static func FunctionNames() throws {
        let input: String = """
        function(_:)
        """
        let expected: String = """
        function(_:)
        """

        #expect(self.format(input) == expected + "\n")
    }
}
extension ColonSpacingTests {
    private static func format(_ input: consuming String) -> String {
        let formatter: WhitespaceFormatter = .init { $0.formatColonPadding = true }
        var input: String = input
        formatter.reformat(&input, check: true)
        return input
    }
}
