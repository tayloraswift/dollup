import Testing
import WhitespaceFormatter

@Suite struct ReindentationTests {
    @Test static func BasicInsertion() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func BasicRemoval() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func If() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func FunctionDeclaration() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func SubscriptDeclaration() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func SubscriptDeclarationWithSetter() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func BinaryOperator() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func TernaryOperator() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func PredicateWhereClause() throws {
        let input: String = """
        func f() {
        for x: Int in sequence
        where x > 0 {
        print(x)
        }
        }
        """
        let expected: String = """
        func f() {
            for x: Int in sequence
                where x > 0 {
                print(x)
            }
        }
        """

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func GenericWhereClause() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func GenericWhereClauseNewline() throws {
        let input: String = """
        struct Foo<Bar>
        where Bar: Equatable & Hashable,
        Bar: Comparable,
                Bar: Sequence {
                }
        """
        let expected: String = """
        struct Foo<Bar>
            where Bar: Equatable & Hashable,
            Bar: Comparable,
            Bar: Sequence {
        }
        """

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func InheritanceClause() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func Nested() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test static func MultilineStringLiteralLeadingWhitespace() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MultilineStringLiteralTrailingWhitespace() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MultilineStringLiteralInterpolationWhitespace() throws {
        let input: String = """
        let x: String = \"""
                \\(1)  \n\
            \"""
        """
        let expected: String = #"""
        let x: String = """
            \(1) \u{20}
        """
        """#

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MultilineStringLiteralInterpolationInterspersed() throws {
        let input: String = """
        let x: String = \"""
                \\(1)  \\(2)\n\
                \\(1)  \\(2) \\(3)\n\
                \\(1)  \\(2) \\(3) \n\
            \\(1)  \\(2)\n\
            \\(1)  \\(2) \\(3)\n\
            \\(1)  \\(2) \\(3) \n\
                    \\(
                        1 + 2 + 3
            ) \n\
            \"""
        """
        let expected: String = #"""
        let x: String = """
            \(1)  \(2)
            \(1)  \(2) \(3)
            \(1)  \(2) \(3)\u{20}
        \(1)  \(2)
        \(1)  \(2) \(3)
        \(1)  \(2) \(3)\u{20}
                \(
            1 + 2 + 3
        )\u{20}
        """
        """#

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MultilineStringLiteralInterpolationEscapedLinebreaks() throws {
        let input: String = #"""
        let x: String = """
                \(1)  \(2)\
                \(1)  \(2) \(3)\
                \(1)  \(2) \(3) \
            \(1)  \(2)\
            \(1)  \(2) \(3)\
            \(1)  \(2) \(3) \
                    \(
                        1 + 2 + 3
            )
            """
        """#
        let expected: String = #"""
        let x: String = """
            \(1)  \(2)\
            \(1)  \(2) \(3)\
            \(1)  \(2) \(3) \
        \(1)  \(2)\
        \(1)  \(2) \(3)\
        \(1)  \(2) \(3) \
                \(
            1 + 2 + 3
        )
        """
        """#

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MultilineStringLiteralWithPoundDelimiter() throws {
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

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test static func BlockCommentPreservation() throws {
        let input: String = """
            /* This is a
            block comment
                that should be preserved as-is */
        """
        let expected: String = """
        /* This is a
            block comment
                that should be preserved as-is */
        """

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test static func IfConfig() throws {
        let input: String = """
            #if os(iOS)
        let x: Int = 1
        #else
                let x: Int = 2
        #endif
        """
        let expected: String = """
        #if os(iOS)
            let x: Int = 1
        #else
            let x: Int = 2
        #endif
        """

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test static func MemberAccess() throws {
        let input: String = """
        let x: [Int] = foo
        .map { $0 + 1 }
            .filter { $0 > 0 }
                .sorted()
        """
        let expected: String = """
        let x: [Int] = foo
            .map { $0 + 1 }
            .filter { $0 > 0 }
            .sorted()
        """

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func LeadingDot() throws {
        let input: String = """
        let x: [Int] = foo(
        .init("abc")
        )
        """
        let expected: String = """
        let x: [Int] = foo(
            .init("abc")
        )
        """

        #expect(try WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
}
