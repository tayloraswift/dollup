import Testing
import BlockIndentFormatter

@Suite struct ReindentationTests {
    @Test static func BasicInsertion() {
        let input: String = """
        Foo.foo(
        arg1: 1,
        arg2: 2,
        arg3: 3,
        )
        """
        let expected: String = """
        Foo.foo(
            arg1: 1,
            arg2: 2,
            arg3: 3,
        )
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func BasicRemoval() {
        let input: String = """
            Foo.foo(
                        arg1: 1,
                arg2: 2,
                    arg3: 3,
                )
        """
        let expected: String = """
        Foo.foo(
            arg1: 1,
            arg2: 2,
            arg3: 3,
        )
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func If() async throws {
        let input: String = """
        if  let x: Int,
        let y: String {
        print(x)
        if  x == 0,
        y == "hello" {
        print(y)
        }
        }
        """
        let expected: String = """
        if  let x: Int,
            let y: String {
            print(x)
            if  x == 0,
                y == "hello" {
                print(y)
            }
        }
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func FunctionDeclaration() {
        let input: String = """
        func myFunction(
        arg1: Int,
        arg2: String,
        arg3: Double
        ) -> () {
        print(arg1)
        }
        """
        let expected: String = """
        func myFunction(
            arg1: Int,
            arg2: String,
            arg3: Double
        ) -> () {
            print(arg1)
        }
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func SubscriptDeclaration() {
        let input: String = """
        struct S {
        subscript(
        index: Int
        ) -> Int {
        return self.buffer[index]
        }
        }
        """
        let expected: String = """
        struct S {
            subscript(
                index: Int
            ) -> Int {
                return self.buffer[index]
            }
        }
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func SubscriptDeclarationWithSetter() {
        let input: String = """
        extension S {
        subscript(
        index: Int
        ) -> Int {
        _read {
        yield self.buffer[index]
        }
        _modify {
        yield &self.buffer[index]
        }
        set(value) {
        self.buffer[index] = value
        }
        }
        }
        """
        let expected: String = """
        extension S {
            subscript(
                index: Int
            ) -> Int {
                _read {
                    yield self.buffer[index]
                }
                _modify {
                    yield &self.buffer[index]
                }
                set(value) {
                    self.buffer[index] = value
                }
            }
        }
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func BinaryOperator() {
        let input: String = """
        let x: Int = foo
        + a
        * (
        b +
        c
        ) - d
        - e
        """
        let expected: String = """
        let x: Int = foo
            + a
            * (
            b +
            c
        ) - d
            - e
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func TernaryOperator() {
        let input: String = """
        let x: Int = foo
        ? bar(x, y)
        : baz(a, b, c)
        """
        let expected: String = """
        let x: Int = foo
            ? bar(x, y)
            : baz(a, b, c)
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func GenericWhereClause() {
        let input: String = """
        struct Foo<Bar> where Bar: Equatable & Hashable,
        Bar: Comparable,
                Bar: Sequence {
                }
        """
        let expected: String = """
        struct Foo<Bar> where Bar: Equatable & Hashable,
            Bar: Comparable,
            Bar: Sequence {
        }
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func InheritanceClause() {
        let input: String = """
        protocol Foo: Equatable,
        Hashable,
        CustomStringConvertible {
        }
        """
        let expected: String = """
        protocol Foo: Equatable,
            Hashable,
            CustomStringConvertible {
        }
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func Nested() {
        let input: String = """
        enum E {
        case x(
        Int
        String
        )
            case y
            }

        extension E {
                static func f(
                    foo: Int?,
                        bar: String,
                    ) {
                    guard
            let foo: Int else {
            return
            }
                }
        }
        """
        let expected: String = """
        enum E {
            case x(
                Int
                String
            )
            case y
        }

        extension E {
            static func f(
                foo: Int?,
                bar: String,
            ) {
                guard
                let foo: Int else {
                    return
                }
            }
        }
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test func MultilineStringLiteralLeadingWhitespace() {
        let input: String = #"""
        let x: String = """
                    foo \(1)
                bar
            """
        """#
        let expected: String = #"""
        let x: String = """
                foo \(1)
            bar
        """
        """#

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test func MultilineStringLiteralTrailingWhitespace() {
        let input: String = """
        let x: String = \"""
                foo \\(1) \n\
                bar  \n\
                baz
            \"""
        """
        let expected: String = #"""
        let x: String = """
            foo \(1)\u{20}
            bar \u{20}
            baz
        """
        """#

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test func MultilineStringLiteralWithPoundDelimiter() {
        let input: String = """
        let x: String = #\"""
                foo \\#(1) \n\
                bar  \n\
                baz
            \"""#
        """
        let expected: String = """
        let x: String = #\"""
            foo \\#(1) \n\
            bar  \n\
            baz
        \"""#
        """

        #expect(BlockIndentFormatter.reindent(input, by: 4) == expected + "\n")
    }
}
