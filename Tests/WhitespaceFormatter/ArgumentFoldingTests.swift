import Testing
import WhitespaceFormatter

@Suite struct ArgumentFoldingTests {
    @Test static func Labeled() throws {
        let input: String = """
        public struct Foo {
            func foo() {
                self.f(
                    x:
                    xValue
                    ,
                    y:
                    yValue
                    ,
                )
            }
        }
        """
        let expected: String = """
        public struct Foo {
            func foo() {
                self.f(
                    x: xValue,
                    y: yValue,
                )
            }
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
    @Test static func Unlabeled() throws {
        let input: String = """
        public struct Foo {
            func foo() {
                self.f(
                    xValue
                    ,
                    yValue
                    ,
                )
            }
        }
        """
        let expected: String = """
        public struct Foo {
            func foo() {
                self.f(
                    xValue,
                    yValue,
                )
            }
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
}
extension ArgumentFoldingTests {
    private static func format(_ input: consuming String) -> String {
        let formatter: WhitespaceFormatter = .init { $0.foldArguments = true }
        var input: String = input
        formatter.reformat(&input, check: true)
        return input
    }
}
