import SwiftSyntax

final class VerticalKeywordCalculator: SyntaxVisitor {
    private(set) var movable: Set<AbsolutePosition>

    init() {
        self.movable = []
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: AccessorDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || node.modifier != nil {
            self.mark(movable: node.accessorSpecifier)
        }
        return .visitChildren
    }
    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.actorKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: AssociatedTypeDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.associatedtypeKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.classKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: DeinitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.deinitKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.caseKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.enumKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.extensionKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.funcKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.importKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.initKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: MacroDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.macroKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.precedencegroupKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.protocolKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.structKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.subscriptKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: TypeAliasDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.typealiasKeyword)
        }
        return .visitChildren
    }
    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        if !node.attributes.isEmpty || !node.modifiers.isEmpty {
            self.mark(movable: node.bindingSpecifier)
        }
        return .visitChildren
    }


    override func visit(_ node: AccessorEffectSpecifiersSyntax) -> SyntaxVisitorContinueKind {
        self.movable.insert(node.positionAfterSkippingLeadingTrivia)
        return .visitChildren
    }

    override func visit(_ node: FunctionEffectSpecifiersSyntax) -> SyntaxVisitorContinueKind {
        self.movable.insert(node.positionAfterSkippingLeadingTrivia)
        return .visitChildren
    }

    override func visit(_ node: DeclModifierListSyntax) -> SyntaxVisitorContinueKind {
        if  node.isEmpty {
            return .skipChildren
        }

        let position: AbsolutePosition = node.positionAfterSkippingLeadingTrivia
        var first: Bool
        if  case position? = node.parent?.positionAfterSkippingLeadingTrivia {
            first = true
        } else {
            first = false
        }

        for modifier: DeclModifierSyntax in node {
            if  first {
                first = false
            } else {
                self.mark(movable: modifier.name)
            }
        }

        return .visitChildren
    }
}
extension VerticalKeywordCalculator {
    private func mark(movable node: TokenSyntax) {
        self.movable.insert(node.positionAfterSkippingLeadingTrivia)
    }
}
