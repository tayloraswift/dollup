import Testing
@testable import RectangleCorrector

@Suite struct RectangleCorrectorTests {

    @Test func FunctionCallFormatting() {
        let input: String = "myFunction(arg1: 1, arg2: 2, arg3: 3, arg4: 4, arg5: 5, arg6: 6, arg7: 7, arg8: 8, arg9: 9, arg10: 10)"
        let expected: String = """
        myFunction(
            arg1: 1,
            arg2: 2,
            arg3: 3,
            arg4: 4,
            arg5: 5,
            arg6: 6,
            arg7: 7,
            arg8: 8,
            arg9: 9,
            arg10: 10
        )
        """

        let actual: String = RectangleCorrector.correct(input, maxLength: 80)

        #expect(actual == expected)
    }

    @Test func NestedFunctionCallFormatting() {
        let input: String = "myFunction(arg1: anotherFunction(arg1: 1, arg2: 2), arg2: 3, arg3: 4, arg4: 5, arg5: 6, arg6: 7)"
        let expected: String = """
        myFunction(
            arg1: anotherFunction(arg1: 1, arg2: 2),
            arg2: 3,
            arg3: 4,
            arg4: 5,
            arg5: 6,
            arg6: 7
        )
        """

        let actual: String = RectangleCorrector.correct(input, maxLength: 80)

        #expect(actual == expected)
    }

    @Test func FunctionDeclarationFormatting() {
        let input: String = "func myFunction(arg1: Int, arg2: String, arg3: Double, arg4: Bool, arg5: Int, arg6: String, arg7: Double) -> Void"
        let expected: String = """
        func myFunction(
            arg1: Int,
            arg2: String,
            arg3: Double,
            arg4: Bool,
            arg5: Int,
            arg6: String,
            arg7: Double
        ) -> Void
        """

        let actual: String = RectangleCorrector.correct(input, maxLength: 80)

        #expect(actual == expected)
    }

    @Test func TrailingClosureFormatting() {
        let input: String = "myFunction(arg1: 1, arg2: 2, arg3: 3) { print(\"hello\") }"
        let expected: String = """
        myFunction(arg1: 1, arg2: 2, arg3: 3) {
            print(\"hello\")
        }
        """

        let actual: String = RectangleCorrector.correct(input, maxLength: 40)

        #expect(actual == expected)
    }
}
