import Testing
@testable import RectangleCorrector

@Test func functionCallFormatting() {
    let input = "myFunction(arg1: 1, arg2: 2, arg3: 3, arg4: 4, arg5: 5, arg6: 6, arg7: 7, arg8: 8, arg9: 9, arg10: 10)"
    let expected = """
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

    let actual = RectangleCorrector.correct(input, maxLength: 80)

    #expect(actual == expected)
}

@Test func nestedFunctionCallFormatting() {
    let input = "myFunction(arg1: anotherFunction(arg1: 1, arg2: 2), arg2: 3, arg3: 4, arg4: 5, arg5: 6, arg6: 7)"
    let expected = """
    myFunction(
        arg1: anotherFunction(arg1: 1, arg2: 2),
        arg2: 3,
        arg3: 4,
        arg4: 5,
        arg5: 6,
        arg6: 7
    )
    """

    let actual = RectangleCorrector.correct(input, maxLength: 80)

    #expect(actual == expected)
}

@Test func functionDeclarationFormatting() {
    let input = "func myFunction(arg1: Int, arg2: String, arg3: Double, arg4: Bool, arg5: Int, arg6: String, arg7: Double) -> Void"
    let expected = """
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

    let actual = RectangleCorrector.correct(input, maxLength: 80)

    #expect(actual == expected)
}

@Test func trailingClosureFormatting() {
    let input = "myFunction(arg1: 1, arg2: 2, arg3: 3) { print(\"hello\") }"
    let expected = """
    myFunction(arg1: 1, arg2: 2, arg3: 3) {
        print(\"hello\")
    }
    """

    let actual = RectangleCorrector.correct(input, maxLength: 40)

    #expect(actual == expected)
}
