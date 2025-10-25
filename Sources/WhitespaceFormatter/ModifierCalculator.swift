import SwiftSyntax

final class ModifierCalculator: SyntaxVisitor {
    private(set) var movable: Set<AbsolutePosition>
    private let options: AttributesOptions

    init(fold options: AttributesOptions) {
        self.movable = []
        self.options = options
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: AccessorDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifier.map { [$0] } ?? [],
            keyword: node.accessorSpecifier
        )
        return .visitChildren
    }
    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.actorKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: AssociatedTypeDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.associatedtypeKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.classKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: DeinitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.deinitKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.caseKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.enumKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.extensionKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.funcKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.importKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.initKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: MacroDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.macroKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.precedencegroupKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.protocolKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.structKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.subscriptKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: TypeAliasDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.typealiasKeyword
        )
        return .visitChildren
    }
    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        self.fold(
            attributes: node.attributes,
            modifiers: node.modifiers,
            keyword: node.bindingSpecifier
        )
        return .visitChildren
    }

    override func visit(_ node: AccessorEffectSpecifiersSyntax) -> SyntaxVisitorContinueKind {
        if  let first: TokenSyntax = node.firstToken(viewMode: .sourceAccurate) {
            self.mark(movable: first)
        }
        return .visitChildren
    }

    override func visit(_ node: FunctionEffectSpecifiersSyntax) -> SyntaxVisitorContinueKind {
        if  let first: TokenSyntax = node.firstToken(viewMode: .sourceAccurate) {
            self.mark(movable: first)
        }
        return .visitChildren
    }
}
extension ModifierCalculator {
    private func fold(
        attributes: AttributeListSyntax,
        modifiers: some Collection<DeclModifierSyntax>,
        keyword: TokenSyntax
    ) {
        var first: Bool = true
        for attribute: AttributeListSyntax.Element in attributes {
            if case .attribute(let attribute) = attribute {
                if !first {
                    self.mark(movable: attribute.atSign)
                }
                first = !self.options.applies(to: attribute)
            } else {
                first = false
            }
        }
        for modifier: DeclModifierSyntax in modifiers {
            if  first {
                first = false
            } else {
                self.mark(movable: modifier.name)
            }
        }
        if !first {
            self.mark(movable: keyword)
        }
    }

    private func mark(movable node: TokenSyntax) {
        self.movable.insert(node.positionAfterSkippingLeadingTrivia)
    }
}
