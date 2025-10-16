import Testing
import WhitespaceFormatter

@Suite struct VerticalKeywordAlignmentTests {
    @Test static func ModifiersOnly() throws {
        let input: String = """
        public
        struct Foo {
            private
            static func bar() {}
        }
        """
        let expected: String = """
        public struct Foo {
            private static func bar() {}
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
    @Test static func ModifiersWithAttributes() throws {
        let input: String = """
        @frozen
        public
        struct Foo {
            @inlinable
            public
            static func bar() {}
        }
        """
        let expected: String = """
        @frozen public struct Foo {
            @inlinable public static func bar() {}
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
    @Test static func EffectsSpecifiers() throws {
        let input: String = """
        public struct Foo {
            @inlinable
            public
            static func bar()
                async throws {}

            public
            subscript(index: Int) -> Int {
                get
                async throws { 0 }
            }
            public internal(set)
            subscript(index: Int) -> String {
                get { 0 }

                @inlinable
                set(value) {}
            }
        }
        """
        let expected: String = """
        public struct Foo {
            @inlinable public static func bar() async throws {}

            public subscript(index: Int) -> Int {
                get async throws { 0 }
            }
            public internal(set) subscript(index: Int) -> String {
                get { 0 }

                @inlinable set(value) {}
            }
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
    @Test static func MultipleAttributes() throws {
        let input: String = """
        public struct Foo {
            @available(*, deprecated)
            @inline(__always)
            @inlinable
            public
            static func foo() async throws {}
        }
        """
        let expected: String = """
        public struct Foo {
            @available(*, deprecated)
            @inline(__always) @inlinable public static func foo() async throws {}
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
    @Test static func LongAttributes() throws {
        let input: String = """
        public struct Foo {
            @available(*, unavailable, message: "Use `foo()` instead", renamed: "foo")
            public
            static func bar() async throws {}

            @inline(__always)
            func baz() {}

            @CustomMacro(a: "blah blah", b: "blah blah", c: "blah", d: "blah")
            public
            static func qux() {}
        }
        """
        let expected: String = """
        public struct Foo {
            @available(*, unavailable, message: "Use `foo()` instead", renamed: "foo")
            public static func bar() async throws {}

            @inline(__always) func baz() {}

            @CustomMacro(a: "blah blah", b: "blah blah", c: "blah", d: "blah")
            public static func qux() {}
        }
        """

        #expect(self.format(input) == expected + "\n")
    }
}
extension VerticalKeywordAlignmentTests {
    private static func format(_ input: consuming String) -> String {
        let formatter: WhitespaceFormatter = .init { $0.foldKeywords = true }
        var input: String = input
        formatter.reformat(&input, check: true)
        return input
    }
}
