import Testing
import BlockIndentFormatter

@Suite struct LineWrappingTests {
    @Test func FunctionCall() {
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

        #expect(BlockIndentFormatter.reformat(input, width: 80) == expected + "\n")
    }

    @Test func NestedFunctionCall() {
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

        #expect(BlockIndentFormatter.reformat(input, width: 80) == expected + "\n")
    }

    @Test func FunctionDeclaration() {
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

        #expect(BlockIndentFormatter.reformat(input, width: 80) == expected + "\n")
    }

    @Test func TrailingClosure() {
        let input: String = """
        myFunction(arg1: 1, arg2: 2) { print("this is a very long line that should be wrapped") }
        """
        let expected: String = """
        myFunction(arg1: 1, arg2: 2) {
            print(
                \"""
                this is a very long line that should be wrapped
                \"""
            )
        }
        """

        #expect(BlockIndentFormatter.reformat(input, width: 40) == expected + "\n")
    }

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

        #expect(BlockIndentFormatter.reformat(input, width: 40) == expected + "\n")
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

        #expect(BlockIndentFormatter.reformat(input, width: 40) == expected + "\n")
    }

    @Test func IfLetElseLet() {
        let input: String = """
        // This line is too long

        if let users = fetchUsers(from: "production", sortedBy: "lastName", activeSince: Date.now, withPermissions: .admin) {
            print(users)
        } else if let users = fetchUsers(from: "production", sortedBy: "lastName", activeSince: Date.now, withPermissions: .guest) {
            print(users)
        } else {
            print("No users found")
        }
        """
        let expected: String = """
        // This line is too long

        if let users = fetchUsers(
                from: "production",
                sortedBy: "lastName",
                activeSince: Date.now,
                withPermissions: .admin
            ) {
            print(users)
        } else if let users = fetchUsers(
                from: "production",
                sortedBy: "lastName",
                activeSince: Date.now,
                withPermissions: .guest
            ) {
            print(users)
        } else {
            print("No users found")
        }
        """

        #expect(BlockIndentFormatter.reformat(input, width: 40) == expected + "\n")
    }

    @Test func WhileLoopBodyIndentation() {
        let input: String = """
        while i < 10 {
            myFunction(arg1: 1, arg2: 2, arg3: 3, arg4: 4, arg5: 5, arg6: 6, arg7: 7, arg8: 8)
        }
        """
        let expected: String = """
        while i < 10 {
            myFunction(
                arg1: 1,
                arg2: 2,
                arg3: 3,
                arg4: 4,
                arg5: 5,
                arg6: 6,
                arg7: 7,
                arg8: 8
            )
        }
        """

        #expect(BlockIndentFormatter.reformat(input, width: 80) == expected + "\n")
    }

    @Test func Attribute() {
        let input: String = """
        @MacroWithVeryLongName(foo: "foo", bar: "bar", baz: "baz", quux: "quux") enum E {
            case a
            case b
        }
        """
        let expected: String = """
        @MacroWithVeryLongName(
            foo: "foo",
            bar: "bar",
            baz: "baz",
            quux: "quux"
        ) enum E {
            case a
            case b
        }
        """

        #expect(BlockIndentFormatter.reformat(input, width: 40) == expected + "\n")
    }

    @Test func Parentheses() {
        let input: String = """
        let x: Int = (foo + bar + baz - qux) * (foo - bar + baz + qux)
        """

        let expected: String = """
        let x: Int = (
            foo + bar + baz - qux
        ) * (
            foo - bar + baz + qux
        )
        """

        #expect(BlockIndentFormatter.reformat(input, width: 24) == expected + "\n")
    }

    @Test func GenericArguments() {
        let input: String = """
        func f(
            x: TypeName<Generic<VeryLongTypeName>, Generic<AnotherVeryLongTypeName>>
        )
        """
        let expected: String = """
        func f(
            x: TypeName<
                Generic<VeryLongTypeName>,
                Generic<AnotherVeryLongTypeName>
            >
        )
        """

        #expect(BlockIndentFormatter.reformat(input, width: 40) == expected + "\n")
    }

    @Test func GenericWhereClause() {
        let input: String = """
        func f<T>(
            x: TypeName<Generic<T>, Generic<AVeryLongTypeName>>
        ) -> Int where Generic<T>: ProtocolWithLongName, T: AnotherProtocolWithLongName {
        }
        """
        let expected: String = """
        func f<T>(
            x: TypeName<
                Generic<T>,
                Generic<AVeryLongTypeName>
            >
        ) -> Int where Generic<T>: ProtocolWithLongName,
            T: AnotherProtocolWithLongName {
        }
        """

        #expect(BlockIndentFormatter.reformat(input, width: 40) == expected + "\n")
    }

    // @Test func StringLiteralOfWhitespace() {
    //     let input: String = """
    //     let x: String = "        "
    //     """
    //     let expected: String = """
    //             \
    //     """

    //     #expect(BlockIndentFormatter.reformat(input, width: 20) == expected + "\n")
    // }
}
