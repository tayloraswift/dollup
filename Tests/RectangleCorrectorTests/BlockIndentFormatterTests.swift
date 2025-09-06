import Testing
import BlockIndentFormatter

@Suite struct BlockIndentFormatterTests {
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

        let actual: String = BlockIndentFormatter.correct(input, length: 80)

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

        let actual: String = BlockIndentFormatter.correct(input, length: 80)

        #expect(actual == expected)
    }

    @Test func FunctionDeclarationFormatting() {
        let input: String = """
        func myFunction(arg1: Int, arg2: String, arg3: Double, arg4: Bool, arg5: Int, arg6: String, arg7: Double) -> Void
        """
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

        let actual: String = BlockIndentFormatter.correct(input, length: 80)

        #expect(actual == expected)
    }

    // @Test func TrailingClosureFormatting() {
    //     let input: String = """
    //     myFunction(arg1: 1, arg2: 2, arg3: 3) { print(\"hello\") }
    //     """
    //     let expected: String = """
    //     myFunction(arg1: 1, arg2: 2, arg3: 3) {
    //         print(\"hello\")
    //     }
    //     """

    //     let actual: String = RectangleCorrector.correct(input, length: 40)

    //     #expect(actual == expected)
    // }

    @Test func InstanceFunction() {
        let input: String = """
        struct S {
            func foo(arg1: Int, arg2: String, arg3: Double, arg4: Bool, arg5: Int, arg6: String, arg7: Double) -> Void {
                print("Hello, World!")
            }
        }
        """
        let expected: String = """
        struct S {
            func foo(
                arg1: Int,
                arg2: String,
                arg3: Double,
                arg4: Bool,
                arg5: Int,
                arg6: String,
                arg7: Double
            ) -> Void {
                print("Hello, World!")
            }
        }
        """

        let actual: String = BlockIndentFormatter.correct(input, length: 40)

        #expect(actual == expected)
    }

    @Test func IfLet() {
        let input: String = """
        // This line is too long
        if  let users = fetchUsers(from: "production", sortedBy: "lastName", activeSince: Date.now, withPermissions: .admin) {
            print(users)
        }
        """
        let expected: String = """
        // This line is too long
        if  let users = fetchUsers(
                from: "production",
                sortedBy: "lastName",
                activeSince: Date.now,
                withPermissions: .admin
            ) {
            print(users)
        }
        """

        let actual: String = BlockIndentFormatter.correct(input, length: 40)

        #expect(actual == expected)
    }
}
