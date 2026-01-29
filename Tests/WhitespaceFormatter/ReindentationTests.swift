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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func FunctionType() throws {
        let input: String = """
        let f: (
        Int,
        String,
        Double
        ) -> ()
        """
        let expected: String = """
        let f: (
            Int,
            String,
            Double
        ) -> ()
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MultilineStringLiteralTrailingEscapedNewline() throws {
        let input: String = #"""
        x += """
            foo
                bar\n
            """
        """#
        let expected: String = #"""
        x += """
        foo
            bar\n
        """
        """#

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func IfConfigPostfix() throws {
        let input: String = """
        let x: [Int] = foo
        .map { $0 + 1 }
        #if FOO
            .filter { $0 > 0 }
        #endif
                .sorted()
                .sorted()
        """
        let expected: String = """
        let x: [Int] = foo
            .map { $0 + 1 }
            #if FOO
                .filter { $0 > 0 }
            #endif
            .sorted()
            .sorted()
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func IfConfigPostfixSolitary() throws {
        let input: String = """
        let x: [Int] = foo
        .map { $0 + 1 }
        #if FOO
            .filter { $0 > 0 }
        #endif
        """
        let expected: String = """
        let x: [Int] = foo
            .map { $0 + 1 }
            #if FOO
                .filter { $0 > 0 }
            #endif
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MemberAccessMultiline() throws {
        let input: String = """
        let x: [Int] = foo
        .map {
        $0 + 1
        }
            .filter {
            $0 > 0
            }
                .sorted()
        """
        let expected: String = """
        let x: [Int] = foo
            .map {
                $0 + 1
            }
            .filter {
                $0 > 0
            }
            .sorted()
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MemberAccessBuilders() throws {
        let input: String = """
        if condition {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .font(.system(.callout))
                .foregroundStyle(
                Color.accentColor
                )
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                if pinnedMarkets.contains(market) {
                    pinnedMarkets.removeAll { $0 == market }
                } else {
                    pinnedMarkets.append(market)
                }
            }
        } else {
            Image(
            systemName: isPinned ? "pin.fill" : "pin"
            )
                .font(.system(.callout))
                .hidden()
        }
        """
        let expected: String = """
        if condition {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .font(.system(.callout))
                .foregroundStyle(
                    Color.accentColor
                )
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    if pinnedMarkets.contains(market) {
                        pinnedMarkets.removeAll { $0 == market }
                    } else {
                        pinnedMarkets.append(market)
                    }
                }
        } else {
            Image(
                systemName: isPinned ? "pin.fill" : "pin"
            )
            .font(.system(.callout))
            .hidden()
        }
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func MemberAccessAfterMultilineTrailingClosure() throws {
        let input: String = """
        if condition {
            Button("Cancel") {
                isShowingCurrencyPicker = false
            }
                .keyboardShortcut(.cancelAction)
        } else if other {
            Button("Cancel") { isShowingCurrencyPicker = false }
                .keyboardShortcut(.cancelAction)
                .keyboardShortcut(.cancelAction)
        } else {
            Button("Cancel") {
                isShowingCurrencyPicker = false
            }
                .keyboardShortcut(.cancelAction)
                .keyboardShortcut(.cancelAction)
        }
        """
        let expected: String = """
        if condition {
            Button("Cancel") {
                isShowingCurrencyPicker = false
            }
            .keyboardShortcut(.cancelAction)
        } else if other {
            Button("Cancel") { isShowingCurrencyPicker = false }
                .keyboardShortcut(.cancelAction)
                .keyboardShortcut(.cancelAction)
        } else {
            Button("Cancel") {
                isShowingCurrencyPicker = false
            }
            .keyboardShortcut(.cancelAction)
            .keyboardShortcut(.cancelAction)
        }
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
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

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test static func ClosureParameters() throws {
        let input: String = """
        foo(1) {
        (
        x: Int,
        y: String
        ) -> Bool in
        }
        """
        let expected: String = """
        foo(1) {
            (
                x: Int,
                y: String
            ) -> Bool in
        }
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }

    @Test static func HangingIf() throws {
        let input: String = """
        if  condition,
        !array.isEmpty,
        let x: Int = array.first,
        x > 0,
        x < 10,
        foo.bar() {
        }
        if let x: Int,
        x > 0 {
        }
        """
        let expected: String = """
        if  condition,
           !array.isEmpty,
            let x: Int = array.first,
                x > 0,
                x < 10,
            foo.bar() {
        }
        if let x: Int,
            x > 0 {
        }
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func HangingIfLet() throws {
        let input: String = """
        func foo() {
            if  let x: Int,
            x > 0 {
            } else if let y: String,
            y.isEmpty {
            }
        }
        """
        let expected: String = """
        func foo() {
            if  let x: Int,
                    x > 0 {
            } else if let y: String,
                y.isEmpty {
            }
        }
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
    @Test static func HangingGuard() throws {
        let input: String = """
        func f() {
            guard foo.bar(),
            !array.isEmpty,
            let x: Int = array.first,
            x > 0,
            !x.isMultiple(of: 5),
            x < 10 else {
                return
            }
        }
        """
        let expected: String = """
        func f() {
            guard foo.bar(),
            !array.isEmpty,
            let x: Int = array.first,
                x > 0,
               !x.isMultiple(of: 5),
                x < 10 else {
                return
            }
        }
        """

        try #expect(WhitespaceFormatter.reindent(input, by: 4) == expected + "\n")
    }
}
