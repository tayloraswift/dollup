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
}
