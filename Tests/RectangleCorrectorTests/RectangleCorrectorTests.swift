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

    #expect(actual.trimmingWhitespace() == expected.trimmingWhitespace())
}