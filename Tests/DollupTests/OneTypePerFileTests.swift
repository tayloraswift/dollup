import Dollup
import SwiftDiagnostics
import SystemIO
import Testing

@Suite struct OneTypePerFileTests {
    @Test static func LayoutFileValid() {
        let source: String = """
        public struct Foo {
            public var x: Int
        }
        extension Foo {
            public func bar() {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.isEmpty)
    }

    @Test static func LayoutFileMismatch() {
        let source: String = """
        public struct Bar {}
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.count == 1)
        #expect(diags.first?.message.contains("does not match filename") == true)
    }

    @Test static func LayoutFileMultipleTypes() {
        let source: String = """
        public struct Foo {}
        public struct Bar {}
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.count == 1)
        #expect(
            diags.first?.message.contains(
                "found type 'Bar' in file 'Foo.swift' which defines 'Foo'"
            ) == true
        )
    }

    @Test static func LayoutFileNestedTypeViolation() {
        let source: String = """
        public struct Foo {
            public struct Nested {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.count == 1)
        #expect(
            diags.first?.message.contains(
                "nested type 'Nested' must be defined in its own file 'Foo.Nested.swift'"
            ) == true
        )
    }

    @Test static func LayoutFileForeignExtension() {
        let source: String = """
        public struct Foo {}
        extension Bar {
            public func helper() {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.count == 1)
        #expect(
            diags.first?.message.contains(
                "cannot contain extension to foreign type 'Bar'"
            ) == true
        )
    }

    @Test static func LayoutFileSimpleKeynumExempt() {
        let source: String = """
        public struct Foo {
            public enum CodingKeys: String, CodingKey {
                case id
                case name
            }
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.isEmpty)
    }

    @Test static func LayoutFileComplexKeynumViolates() {
        let source: String = """
        public struct Foo {
            public enum CodingKeys: String, CodingKey {
                case id
                case name
                public var helper: String { "help" }
            }
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.count == 1)
        #expect(
            diags.first?.message.contains(
                "schema keynum 'CodingKeys' has grown members beyond enum cases"
            ) == true
        )
    }

    @Test static func LayoutFileDeprecationShimExempt() {
        let source: String = """
        public struct Foo {}

        @available(*, deprecated, renamed: "Foo")
        public typealias OldFoo = Foo
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.isEmpty)
    }

    @Test static func LayoutFileFreeFunctionAlone() {
        let source: String = """
        public func Partition(slice: inout [Int]) {}
        public func Partition(slice: inout [String]) {}
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Partition.swift")
        )
        #expect(diags.isEmpty)
    }

    @Test static func LayoutFileFreeFunctionWithPrimaryType() {
        let source: String = """
        public struct Foo {}
        public func Foo() {}
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.count == 1)
        #expect(
            diags.first?.message.contains(
                "free function 'Foo' cannot coexist with type 'Foo'"
            ) == true
        )
    }

    @Test static func NestedLayoutFileValid() {
        let source: String = """
        extension Foo {
            public struct Bar {
                public var val: Int
            }
        }
        extension Foo.Bar {
            public func doSomething() {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.Bar.swift")
        )
        #expect(diags.isEmpty)
    }

    @Test static func NestedLayoutFileForeignExtensionSiblingViolation() {
        let source: String = """
        extension Foo {
            public struct Bar {}
            public func sibling() {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.Bar.swift")
        )
        #expect(diags.count == 1)
        #expect(
            diags.first?.message.contains(
                """
                foreign extension to 'Foo' in 'Foo.Bar.swift' must contain nothing except the definition of 'Bar'
                """
            ) == true
        )
    }

    @Test static func NestedLayoutFileTopLevelTypeViolation() {
        let source: String = """
        public struct Bar {}
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.Bar.swift")
        )
        #expect(
            diags.contains {
                $0.message.contains("found top-level type 'Bar' in nested layout file")
            }
        )
    }

    @Test static func ExtensionFileValid() {
        let source: String = """
        extension Foo {
            public func extra() {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo (ext).swift")
        )
        #expect(diags.isEmpty)
    }

    @Test static func ExtensionFileCollectionTypes() {
        let arraySource: String = """
        extension [Int] {
            public func sum() -> Int { 0 }
        }
        extension Array where Element == String {
            public func joinedNames() -> String { "" }
        }
        """
        let arrayDiags: [Diagnostic] = OneTypePerFile.check(
            source: arraySource,
            in: FilePath("Array (ext).swift")
        )
        #expect(arrayDiags.isEmpty)

        let dictSource: String = """
        extension Dictionary where Key == String {
            public func lookup() {}
        }
        """
        let dictDiags: [Diagnostic] = OneTypePerFile.check(
            source: dictSource,
            in: FilePath("Dictionary (ext).swift")
        )
        #expect(dictDiags.isEmpty)
    }

    @Test static func ExtensionFileForeignViolation() {
        let source: String = """
        extension Foo {
            public func f() {}
        }
        extension Bar {
            public func b() {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo (ext).swift")
        )
        #expect(diags.count == 1)
        #expect(diags.first?.message.contains("cannot contain extension to 'Bar'") == true)
    }

    @Test static func ExtensionFilePrimaryTypeViolation() {
        let source: String = """
        public struct Foo {}
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo (ext).swift")
        )
        #expect(diags.count == 1)
        #expect(diags.first?.message.contains("cannot define primary type 'Foo'") == true)
    }

    @Test static func ExtensionFileWitnessTypealias() {
        let source: String = """
        extension Foo: Equatable {
            public typealias Witness = Int
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo (ext).swift")
        )
        #expect(diags.isEmpty)
    }

    @Test static func FilenamePlusSignBanned() {
        let source: String = """
        extension Foo {
            public func bar() {}
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo+Bar.swift")
        )
        #expect(diags.count == 1)
        #expect(
            diags.first?.message.contains(
                "plus signs ('+') are never allowed in filenames"
            ) == true
        )
    }

    @Test static func AnchorSwift() {
        let emptyDiags: [Diagnostic] = OneTypePerFile.check(
            source: "",
            in: FilePath("anchor.swift")
        )
        #expect(emptyDiags.isEmpty)

        let nonEmptyDiags: [Diagnostic] = OneTypePerFile.check(
            source: "import Foundation",
            in: FilePath("anchor.swift")
        )
        #expect(nonEmptyDiags.count == 1)
        #expect(nonEmptyDiags.first?.message.contains("'anchor.swift' must be empty") == true)
    }

    @Test static func ExportsSwift() {
        let validSource: String = """
        @_exported import SystemIO
        @_exported import SwiftSyntax
        """
        let validDiags: [Diagnostic] = OneTypePerFile.check(
            source: validSource,
            in: FilePath("exports.swift")
        )
        #expect(validDiags.isEmpty)

        let invalidSource: String = """
        import SystemIO
        """
        let invalidDiags: [Diagnostic] = OneTypePerFile.check(
            source: invalidSource,
            in: FilePath("exports.swift")
        )
        #expect(invalidDiags.count == 1)
        #expect(
            invalidDiags.first?.message.contains(
                "'exports.swift' can only contain '@_exported import' statements"
            ) == true
        )

        let misplacedExport: String = """
        @_exported import SystemIO
        public struct Foo {}
        """
        let misplacedDiags: [Diagnostic] = OneTypePerFile.check(
            source: misplacedExport,
            in: FilePath("Foo.swift")
        )
        #expect(misplacedDiags.count == 1)
        #expect(
            misplacedDiags.first?.message.contains(
                "'@_exported import' is prohibited outside 'exports.swift'"
            ) == true
        )
    }

    @Test static func LexemesAndOperatorsSwift() {
        let lexemesSource: String = """
        infix operator >< : MultiplicationPrecedence
        precedencegroup CustomPrecedence {
            higherThan: MultiplicationPrecedence
        }
        """
        let lexemesDiags: [Diagnostic] = OneTypePerFile.check(
            source: lexemesSource,
            in: FilePath("lexemes.swift")
        )
        #expect(lexemesDiags.isEmpty)

        let misplacedOperator: String = """
        infix operator >< : MultiplicationPrecedence
        public struct Foo {}
        """
        let misplacedDiags: [Diagnostic] = OneTypePerFile.check(
            source: misplacedOperator,
            in: FilePath("Foo.swift")
        )
        #expect(
            misplacedDiags.contains {
                $0.message.contains(
                    """
                    operator and precedencegroup declarations are prohibited outside 'lexemes.swift'
                    """
                )
            }
        )

        let operatorsSource: String = """
        public func + (a: Foo, b: Foo) -> Foo { a }
        """
        let operatorsDiags: [Diagnostic] = OneTypePerFile.check(
            source: operatorsSource,
            in: FilePath("operators.swift")
        )
        #expect(operatorsDiags.isEmpty)

        let operatorsWithTypes: String = """
        public struct Foo {}
        """
        let operatorsTypeDiags: [Diagnostic] = OneTypePerFile.check(
            source: operatorsWithTypes,
            in: FilePath("operators.swift")
        )
        #expect(operatorsTypeDiags.count == 1)
        #expect(
            operatorsTypeDiags.first?.message.contains(
                "'operators.swift' cannot declare types"
            ) == true
        )
    }

    @Test static func ConditionalCompilationUnrolling() {
        let source: String = """
        public struct Foo {
            #if os(Linux)
            public struct NestedLinux {}
            #else
            public struct NestedDarwin {}
            #endif
        }
        """
        let diags: [Diagnostic] = OneTypePerFile.check(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(diags.count == 2)
        #expect(diags.contains { $0.message.contains("NestedLinux") })
        #expect(diags.contains { $0.message.contains("NestedDarwin") })
    }

    @Test static func DiagnoseFormatting() {
        let source: String = """
        public struct Foo {}
        public struct Bar {}
        """
        let fileDiags: FileDiagnostics? = OneTypePerFile.diagnose(
            source: source,
            in: FilePath("Foo.swift")
        )
        #expect(fileDiags != nil)
        let formatted: String = fileDiags?.description ?? ""
        #expect(formatted.contains("error: in 'Foo.swift':"))
        #expect(formatted.contains("one type per file violation"))
    }
}
