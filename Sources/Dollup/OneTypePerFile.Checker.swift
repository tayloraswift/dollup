import SwiftDiagnostics
import SwiftSyntax
import SystemIO

extension OneTypePerFile {
    struct Checker {
        let file: FilePath
        let filename: String
        let tree: SourceFileSyntax

        var diagnostics: [Diagnostic] = []

        init(tree: SourceFileSyntax, file: FilePath) {
            self.file = file
            self.filename = file.lastComponent?.string ?? ""
            self.tree = tree
        }

        mutating func check() -> [Diagnostic] {
            guard self.filename.hasSuffix(".swift") else {
                return []
            }

            if self.filename.contains("+") {
                self.diagnose(
                    node: Syntax(self.tree),
                    message: """
                    plus signs ('+') are never allowed in filenames; use ' (ext)' for extension files
                    """
                )
                return self.diagnostics
            }

            let stemWithGenOrExt: String = String(self.filename.dropLast(6))

            if stemWithGenOrExt == "Package" {
                return self.diagnostics
            }

            if stemWithGenOrExt == "anchor" {
                if !self.tree.statements.isEmpty {
                    self.diagnose(
                        node: Syntax(self.tree.statements.first!),
                        message: "'anchor.swift' must be empty"
                    )
                }
                return self.diagnostics
            }

            if stemWithGenOrExt == "exports" {
                let statements: [CodeBlockItemSyntax] = self.unrollStatements(
                    self.tree.statements
                )
                for stmt in statements {
                    if case .decl(let decl) = stmt.item,
                        let importDecl: ImportDeclSyntax = decl.as(ImportDeclSyntax.self),
                        self.isExportedImport(importDecl) {
                        continue
                    }
                    self.diagnose(
                        node: Syntax(stmt),
                        message: """
                        'exports.swift' can only contain '@_exported import' statements
                        """
                    )
                }
                return self.diagnostics
            }

            if stemWithGenOrExt == "lexemes" {
                let statements: [CodeBlockItemSyntax] = self.unrollStatements(
                    self.tree.statements
                )
                for stmt in statements {
                    if case .decl(let decl) = stmt.item {
                        if decl.is(OperatorDeclSyntax.self) || decl.is(
                                PrecedenceGroupDeclSyntax.self
                            ) {
                            continue
                        }
                    }
                    self.diagnose(
                        node: Syntax(stmt),
                        message: """
                        'lexemes.swift' can only contain operator and precedencegroup declarations
                        """
                    )
                }
                return self.diagnostics
            }

            if stemWithGenOrExt == "operators" {
                let statements: [CodeBlockItemSyntax] = self.unrollStatements(
                    self.tree.statements
                )
                for stmt in statements {
                    if case .decl(let decl) = stmt.item,
                        self.isPrimaryType(decl) {
                        self.diagnose(
                            node: Syntax(decl),
                            message: """
                            'operators.swift' cannot declare types; it can only contain top-level operator functions
                            """
                        )
                    }
                }
                return self.diagnostics
            }

            self.checkGlobalRestrictions(stemWithGenOrExt: stemWithGenOrExt)

            let isExt: Bool = stemWithGenOrExt.hasSuffix(" (ext)")
            let isGen: Bool = stemWithGenOrExt.hasSuffix(" (gen)")
            if isExt || isGen {
                let expectedType: String = String(stemWithGenOrExt.dropLast(6))
                self.checkExtensionFile(expectedType: expectedType)
                return self.diagnostics
            }

            let stem: String = stemWithGenOrExt
            if stem.contains(".") {
                self.checkNestedLayoutFile(stem: stem)
            } else {
                self.checkTopLevelLayoutFile(stem: stem)
            }

            return self.diagnostics
        }

        private mutating func checkGlobalRestrictions(stemWithGenOrExt: String) {
            let statements: [CodeBlockItemSyntax] = self.unrollStatements(self.tree.statements)
            for stmt in statements {
                guard case .decl(let decl) = stmt.item else {
                    continue
                }
                if let importDecl: ImportDeclSyntax = decl.as(ImportDeclSyntax.self),
                    self.isExportedImport(importDecl) {
                    self.diagnose(
                        node: Syntax(importDecl),
                        message: "'@_exported import' is prohibited outside 'exports.swift'"
                    )
                }
                if decl.is(OperatorDeclSyntax.self) || decl.is(PrecedenceGroupDeclSyntax.self) {
                    self.diagnose(
                        node: Syntax(decl),
                        message: """
                        operator and precedencegroup declarations are prohibited outside 'lexemes.swift'
                        """
                    )
                }
            }
        }

        private mutating func checkExtensionFile(expectedType: String) {
            let statements: [CodeBlockItemSyntax] = self.unrollStatements(self.tree.statements)
            for stmt in statements {
                guard case .decl(let decl) = stmt.item else {
                    if !stmt.item.is(ImportDeclSyntax.self) {
                        self.diagnose(
                            node: Syntax(stmt),
                            message: """
                            extension file '\(
                                self.filename
                            )' cannot contain top-level executable statements
                            """
                        )
                    }
                    continue
                }

                if decl.is(ImportDeclSyntax.self) {
                    continue
                }

                if let ext: ExtensionDeclSyntax = decl.as(ExtensionDeclSyntax.self) {
                    let target: String = self.canonicalTypeName(of: ext.extendedType)
                    let trimmed: String = ext.extendedType.trimmedDescription
                    if target != expectedType && trimmed != expectedType {
                        self.diagnose(
                            node: Syntax(ext),
                            message: """
                            extension file '\(self.filename)' cannot contain extension to '\(
                                trimmed
                            )'; it must only extend '\(
                                expectedType
                            )'
                            """
                        )
                    }
                    self.checkExtensionMembers(
                        ext.memberBlock.members,
                        parentType: expectedType
                    )
                    continue
                }

                if self.isPrimaryType(decl) {
                    let name: String = self.name(of: decl) ?? "unnamed"
                    self.diagnose(
                        node: Syntax(decl),
                        message: """
                        extension file '\(self.filename)' cannot define primary type '\(name)'
                        """
                    )
                    continue
                }

                if let function: FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self) {
                    self.diagnose(
                        node: Syntax(decl),
                        message: """
                        extension file '\(self.filename)' cannot contain free function '\(
                            function.name.text
                        )'
                        """
                    )
                    continue
                }

                if decl.is(VariableDeclSyntax.self) {
                    self.diagnose(
                        node: Syntax(decl),
                        message: """
                        extension file '\(self.filename)' cannot contain top-level properties
                        """
                    )
                    continue
                }
            }
        }

        private mutating func checkNestedLayoutFile(stem: String) {
            let components: [Substring] = stem.split(separator: ".")
            let outerName: String = components.dropLast().joined(separator: ".")
            let innerName: String = String(components.last!)

            var foreignExtensionCount: Int = 0
            var primaryTypeFound: Bool = false

            let statements: [CodeBlockItemSyntax] = self.unrollStatements(self.tree.statements)
            for stmt in statements {
                guard case .decl(let decl) = stmt.item else {
                    if !stmt.item.is(ImportDeclSyntax.self) {
                        self.diagnose(
                            node: Syntax(stmt),
                            message: """
                            layout file '\(
                                self.filename
                            )' cannot contain top-level executable statements
                            """
                        )
                    }
                    continue
                }

                if decl.is(ImportDeclSyntax.self) {
                    continue
                }

                if let ext: ExtensionDeclSyntax = decl.as(ExtensionDeclSyntax.self) {
                    let target: String = self.canonicalTypeName(of: ext.extendedType)
                    let trimmed: String = ext.extendedType.trimmedDescription

                    if target == outerName || trimmed == outerName {
                        foreignExtensionCount += 1
                        if foreignExtensionCount > 1 {
                            self.diagnose(
                                node: Syntax(ext),
                                message: """
                                layout file '\(
                                    self.filename
                                )' must contain only one extension to namespace '\(
                                    outerName
                                )'
                                """
                            )
                        }
                        let members: [MemberBlockItemSyntax] = self.unrollMembers(
                            ext.memberBlock.members
                        )
                        for member in members {
                            if self.isPrimaryType(member.decl) {
                                let name: String = self.name(of: member.decl) ?? ""
                                if name == innerName {
                                    primaryTypeFound = true
                                    self.checkNestedMembers(member.decl, parentType: stem)
                                } else {
                                    self.diagnose(
                                        node: Syntax(member.decl),
                                        message: """
                                        foreign extension to '\(outerName)' in '\(
                                            self.filename
                                        )' must contain nothing except the definition of '\(
                                            innerName
                                        )'
                                        """
                                    )
                                }
                            } else if let alias: TypeAliasDeclSyntax = member.decl.as(
                                    TypeAliasDeclSyntax.self
                                ) {
                                if alias.name.text == innerName {
                                    primaryTypeFound = true
                                } else {
                                    self.diagnose(
                                        node: Syntax(alias),
                                        message: """
                                        foreign extension to '\(outerName)' in '\(
                                            self.filename
                                        )' must contain nothing except the definition of '\(
                                            innerName
                                        )'
                                        """
                                    )
                                }
                            } else {
                                self.diagnose(
                                    node: Syntax(member.decl),
                                    message: """
                                    foreign extension to '\(outerName)' in '\(
                                        self.filename
                                    )' must contain nothing except the definition of '\(
                                        innerName
                                    )'
                                    """
                                )
                            }
                        }
                    } else if target == stem || trimmed == stem {
                        self.checkExtensionMembers(ext.memberBlock.members, parentType: stem)
                    } else {
                        self.diagnose(
                            node: Syntax(ext),
                            message: """
                            layout file '\(
                                self.filename
                            )' cannot contain extension to foreign type '\(
                                trimmed
                            )'
                            """
                        )
                    }
                    continue
                }

                if self.isPrimaryType(decl) {
                    let name: String = self.name(of: decl) ?? "unnamed"
                    self.diagnose(
                        node: Syntax(decl),
                        message: """
                        one type per file violation: found top-level type '\(
                            name
                        )' in nested layout file '\(
                            self.filename
                        )'
                        """
                    )
                    continue
                }

                if let function: FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self) {
                    self.diagnose(
                        node: Syntax(decl),
                        message: """
                        free function '\(
                            function.name.text
                        )' cannot appear in nested layout file '\(
                            self.filename
                        )'
                        """
                    )
                    continue
                }
            }

            if !primaryTypeFound {
                self.diagnose(
                    node: Syntax(self.tree),
                    message: """
                    layout file '\(self.filename)' must define nested type '\(
                        innerName
                    )' inside 'extension \(
                        outerName
                    )'
                    """
                )
            }
        }

        private mutating func checkTopLevelLayoutFile(stem: String) {
            let statements: [CodeBlockItemSyntax] = self.unrollStatements(self.tree.statements)
            let matchingPrimaryDecl: DeclSyntax? = statements.compactMap { stmt -> DeclSyntax? in
                guard case .decl(let decl) = stmt.item, self.isPrimaryType(decl) else {
                    return nil
                }
                return (self.name(of: decl) == stem) ? decl : nil
            }.first

            var primaryTypeFound: Bool = false
            var matchingFreeFunction: Bool = false
            var matchingTypealias: Bool = false
            var otherPrimaryTypeNames: [String] = []

            for stmt in statements {
                guard case .decl(let decl) = stmt.item else {
                    if stem != "main" && !stmt.item.is(ImportDeclSyntax.self) {
                        self.diagnose(
                            node: Syntax(stmt),
                            message: """
                            layout file '\(
                                self.filename
                            )' cannot contain top-level executable statements
                            """
                        )
                    }
                    continue
                }

                if decl.is(ImportDeclSyntax.self) {
                    continue
                }

                if let ext: ExtensionDeclSyntax = decl.as(ExtensionDeclSyntax.self) {
                    let target: String = self.canonicalTypeName(of: ext.extendedType)
                    let trimmed: String = ext.extendedType.trimmedDescription
                    if target == stem || trimmed == stem {
                        self.checkExtensionMembers(ext.memberBlock.members, parentType: stem)
                    } else {
                        self.diagnose(
                            node: Syntax(ext),
                            message: """
                            layout file '\(
                                self.filename
                            )' cannot contain extension to foreign type '\(
                                trimmed
                            )'
                            """
                        )
                    }
                    continue
                }

                if self.isPrimaryType(decl) {
                    let name: String = self.name(of: decl) ?? ""
                    if name == stem {
                        primaryTypeFound = true
                        self.checkNestedMembers(decl, parentType: stem)
                    } else if matchingPrimaryDecl != nil {
                        self.diagnose(
                            node: Syntax(decl),
                            message: """
                            one type per file violation: found type '\(name)' in file '\(
                                self.filename
                            )' which defines '\(
                                stem
                            )'
                            """
                        )
                    } else {
                        if otherPrimaryTypeNames.isEmpty {
                            self.diagnose(
                                node: Syntax(decl),
                                message: """
                                type '\(name)' does not match filename '\(self.filename)'
                                """
                            )
                        } else {
                            self.diagnose(
                                node: Syntax(decl),
                                message: """
                                one type per file violation: found type '\(name)' in file '\(
                                    self.filename
                                )'
                                """
                            )
                        }
                        otherPrimaryTypeNames.append(name)
                    }
                    continue
                }

                if let macro: MacroDeclSyntax = decl.as(MacroDeclSyntax.self) {
                    if matchingPrimaryDecl != nil {
                        self.diagnose(
                            node: Syntax(decl),
                            message: """
                            macro '\(macro.name.text)' cannot coexist with type '\(stem)' in '\(
                                self.filename
                            )'
                            """
                        )
                    } else if macro.name.text == stem {
                        primaryTypeFound = true
                    } else {
                        self.diagnose(
                            node: Syntax(decl),
                            message: """
                            macro '\(macro.name.text)' does not match filename '\(
                                self.filename
                            )'
                            """
                        )
                    }
                    continue
                }

                if let alias: TypeAliasDeclSyntax = decl.as(TypeAliasDeclSyntax.self) {
                    if self.isDeprecationShim(alias, for: stem) {
                        continue
                    }
                    if matchingPrimaryDecl != nil {
                        self.diagnose(
                            node: Syntax(alias),
                            message: """
                            typealias '\(alias.name.text)' cannot coexist with type '\(
                                stem
                            )' in '\(
                                self.filename
                            )'
                            """
                        )
                    } else if alias.name.text == stem {
                        matchingTypealias = true
                    } else {
                        self.diagnose(
                            node: Syntax(alias),
                            message: """
                            typealias '\(alias.name.text)' does not match filename '\(
                                self.filename
                            )'
                            """
                        )
                    }
                    continue
                }

                if let function: FunctionDeclSyntax = decl.as(FunctionDeclSyntax.self) {
                    if matchingPrimaryDecl != nil {
                        self.diagnose(
                            node: Syntax(decl),
                            message: """
                            free function '\(function.name.text)' cannot coexist with type '\(
                                stem
                            )' in '\(
                                self.filename
                            )'
                            """
                        )
                    } else if function.name.text == stem {
                        matchingFreeFunction = true
                    } else {
                        self.diagnose(
                            node: Syntax(decl),
                            message: """
                            free function '\(function.name.text)' does not match filename '\(
                                self.filename
                            )'
                            """
                        )
                    }
                    continue
                }

                if let variable: VariableDeclSyntax = decl.as(VariableDeclSyntax.self) {
                    for binding in variable.bindings {
                        let propName: String = binding.pattern.trimmedDescription
                        if matchingPrimaryDecl != nil {
                            self.diagnose(
                                node: Syntax(decl),
                                message: """
                                top-level property '\(propName)' cannot coexist with type '\(
                                    stem
                                )' in '\(
                                    self.filename
                                )'
                                """
                            )
                        } else if propName == stem {
                            matchingFreeFunction = true
                        }
                    }
                    continue
                }
            }

            if !primaryTypeFound && !matchingFreeFunction && !matchingTypealias && stem != """
                main
                """ {
                if otherPrimaryTypeNames.isEmpty {
                    self.diagnose(
                        node: Syntax(self.tree),
                        message: "layout file '\(self.filename)' must define type '\(stem)'"
                    )
                }
            }
        }

        private mutating func checkNestedMembers(_ decl: DeclSyntax, parentType: String) {
            let members: MemberBlockItemListSyntax?
            if let s = decl.as(StructDeclSyntax.self) {
                members = s.memberBlock.members
            } else if let c = decl.as(ClassDeclSyntax.self) {
                members = c.memberBlock.members
            } else if let e = decl.as(EnumDeclSyntax.self) {
                members = e.memberBlock.members
            } else if let a = decl.as(ActorDeclSyntax.self) {
                members = a.memberBlock.members
            } else if let p = decl.as(ProtocolDeclSyntax.self) {
                members = p.memberBlock.members
            } else {
                members = nil
            }

            guard let members: MemberBlockItemListSyntax else {
                return
            }
            self.checkExtensionMembers(members, parentType: parentType)
        }

        private mutating func checkExtensionMembers(
            _ members: MemberBlockItemListSyntax,
            parentType: String
        ) {
            let unrolled: [MemberBlockItemSyntax] = self.unrollMembers(members)
            for member in unrolled {
                if let enumDecl: EnumDeclSyntax = member.decl.as(EnumDeclSyntax.self) {
                    let keynum = self.isExemptKeynum(enumDecl)
                    if keynum.isKeynum && keynum.isSimple {
                        continue
                    }
                    if keynum.isKeynum && !keynum.isSimple {
                        self.diagnose(
                            node: Syntax(enumDecl),
                            message: """
                            schema keynum '\(
                                enumDecl.name.text
                            )' has grown members beyond enum cases and must be defined in its own file '\(
                                parentType
                            ).\(
                                enumDecl.name.text
                            ).swift'
                            """
                        )
                        continue
                    }
                    self.diagnose(
                        node: Syntax(enumDecl),
                        message: """
                        nested type '\(enumDecl.name.text)' must be defined in its own file '\(
                            parentType
                        ).\(
                            enumDecl.name.text
                        ).swift'
                        """
                    )
                    continue
                }

                if self.isPrimaryType(member.decl) {
                    let name: String = self.name(of: member.decl) ?? "unnamed"
                    self.diagnose(
                        node: Syntax(member.decl),
                        message: """
                        nested type '\(name)' must be defined in its own file '\(parentType).\(
                            name
                        ).swift'
                        """
                    )
                }
            }
        }

        private mutating func diagnose(node: Syntax, message: String) {
            let diagnostic: Diagnostic = .init(
                node: node,
                position: node.positionAfterSkippingLeadingTrivia,
                message: DiagnosticMessage.init(message)
            )
            self.diagnostics.append(diagnostic)
        }

        private func unrollStatements(
            _ statements: CodeBlockItemListSyntax
        ) -> [CodeBlockItemSyntax] {
            var result: [CodeBlockItemSyntax] = []
            for item in statements {
                if case .decl(let decl) = item.item,
                    let ifConfig: IfConfigDeclSyntax = decl.as(IfConfigDeclSyntax.self) {
                    for clause in ifConfig.clauses {
                        if case .statements(let nested)? = clause.elements {
                            result.append(contentsOf: self.unrollStatements(nested))
                        }
                    }
                } else {
                    result.append(item)
                }
            }
            return result
        }

        private func unrollMembers(
            _ members: MemberBlockItemListSyntax
        ) -> [MemberBlockItemSyntax] {
            var result: [MemberBlockItemSyntax] = []
            for member in members {
                if let ifConfig: IfConfigDeclSyntax = member.decl.as(IfConfigDeclSyntax.self) {
                    for clause in ifConfig.clauses {
                        if case .decls(let nested)? = clause.elements {
                            result.append(contentsOf: self.unrollMembers(nested))
                        }
                    }
                } else {
                    result.append(member)
                }
            }
            return result
        }

        private func canonicalTypeName(of type: TypeSyntax) -> String {
            if type.is(ArrayTypeSyntax.self) {
                return "Array"
            }
            if type.is(DictionaryTypeSyntax.self) {
                return "Dictionary"
            }
            if type.is(OptionalTypeSyntax.self) {
                return "Optional"
            }
            if let member: MemberTypeSyntax = type.as(MemberTypeSyntax.self) {
                let base: String = self.canonicalTypeName(of: member.baseType)
                return "\(base).\(member.name.text)"
            }
            if let identifier: IdentifierTypeSyntax = type.as(IdentifierTypeSyntax.self) {
                return identifier.name.text
            }
            return type.trimmedDescription
        }

        private func isExemptKeynum(_ enumDecl: EnumDeclSyntax) -> (
            isKeynum: Bool,
            isSimple: Bool
        ) {
            let name: String = enumDecl.name.text
            let isKeyName: Bool = name.hasSuffix("Key") || name.hasSuffix("Keys")
            let hasKeyInheritance: Bool = enumDecl.inheritanceClause?.inheritedTypes.contains { inherited in
                let text: String = inherited.type.trimmedDescription
                return text == "CodingKey" || text.hasSuffix(".CodingKey")
            } ?? false

            guard isKeyName || hasKeyInheritance else {
                return (false, false)
            }

            let members: [MemberBlockItemSyntax] = self.unrollMembers(
                enumDecl.memberBlock.members
            )
            var hasCases: Bool = false
            for member in members {
                if member.decl.is(EnumCaseDeclSyntax.self) {
                    hasCases = true
                } else {
                    return (true, false)
                }
            }
            return (true, hasCases)
        }

        private func isDeprecationShim(
            _ alias: TypeAliasDeclSyntax,
            for expectedType: String
        ) -> Bool {
            for attr in alias.attributes {
                guard case .attribute(let attribute) = attr,
                attribute.attributeName.trimmedDescription == "available" else {
                    continue
                }
                let args: String = attribute.arguments?.trimmedDescription ?? ""
                if args.contains("deprecated") {
                    if args.contains("renamed: \"\(expectedType)\"") ||
                        self.canonicalTypeName(of: alias.initializer.value) == expectedType ||
                        alias.initializer.value.trimmedDescription == expectedType {
                        return true
                    }
                }
            }
            return false
        }

        private func isExportedImport(_ importDecl: ImportDeclSyntax) -> Bool {
            for attr in importDecl.attributes {
                if case .attribute(let attribute) = attr,
                    attribute.attributeName.trimmedDescription == "_exported" {
                    return true
                }
            }
            return false
        }

        private func isPrimaryType(_ decl: DeclSyntax) -> Bool {
            decl.is(StructDeclSyntax.self) ||
            decl.is(ClassDeclSyntax.self) ||
            decl.is(EnumDeclSyntax.self) ||
            decl.is(ActorDeclSyntax.self) ||
            decl.is(ProtocolDeclSyntax.self)
        }

        private func name(of decl: DeclSyntax) -> String? {
            if let s = decl.as(StructDeclSyntax.self) { return s.name.text }
            if let c = decl.as(ClassDeclSyntax.self) { return c.name.text }
            if let e = decl.as(EnumDeclSyntax.self) { return e.name.text }
            if let a = decl.as(ActorDeclSyntax.self) { return a.name.text }
            if let p = decl.as(ProtocolDeclSyntax.self) { return p.name.text }
            return nil
        }
    }
}
