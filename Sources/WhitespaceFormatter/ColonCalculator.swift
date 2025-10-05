import SwiftSyntax

final class ColonCalculator: SyntaxVisitor {
    private var colons: [AbsolutePosition: ColonAlignment]

    init() {
        self.colons = [:]
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: TypeAnnotationSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: ClosureParameterSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: TupleTypeElementSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: EnumCaseParameterSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: LabeledExprSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: LabeledStmtSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: MultipleTrailingClosureElementSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: SwitchCaseLabelSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .allowed)
        return .visitChildren
    }

    override func visit(_ node: TernaryExprSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .ternary)
        return .visitChildren
    }

    override func visit(_ node: DictionaryTypeSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: DictionaryElementSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .allowed)
        return .visitChildren
    }

    override func visit(_ node: InheritanceClauseSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: ConformanceRequirementSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: LayoutRequirementSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
    override func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        self.mark(node.colon, as: .disallowed)
        return .visitChildren
    }
}
extension ColonCalculator {
    private func mark(_ token: TokenSyntax?, as alignment: ColonAlignment) {
        guard let token: TokenSyntax else {
            return
        }
        self.mark(token, as: alignment)
    }
    private func mark(_ token: TokenSyntax, as alignment: ColonAlignment) {
        self.colons[token.positionAfterSkippingLeadingTrivia] = alignment
    }
}
extension ColonCalculator {
    func reformat(tokens: TokenSequence) -> String {
        var tokens: TokenSequence.Iterator = tokens.makeIterator()
        var next: TokenSyntax? = tokens.next()
        var text: String = ""

        while let current: TokenSyntax = next {
            next = tokens.next()

            guard let next: TokenSyntax else {
                text += "\(current)"
                break
            }

            if  case .colon = next.tokenKind {
                if case .ternary? = self.colons[next.positionAfterSkippingLeadingTrivia] {
                    // a ternary colon does not need padding
                    text += "\(current)"
                } else {
                    var trailingTrivia: String = "\(current.trailingTrivia)"
                    while case " "? = trailingTrivia.last {
                        trailingTrivia.removeLast()
                    }

                    text += "\(current.with(\.trailingTrivia, []))"
                    text += trailingTrivia
                }
            } else if case .colon = current.tokenKind {
                if  next.leadingTrivia.contains(
                        where: {
                            switch $0 {
                            case .carriageReturnLineFeeds: true
                            case .newlines: true
                            default: false
                            }
                        }
                    ) {
                    // a colon that appears at the end of a line does not need padding
                    text += "\(current)"
                    continue
                }

                if  current.trailingTrivia.isEmpty {
                    // colon needs padding
                    text += "\(current)"
                    text.append(" ")
                    continue
                }

                switch self.colons[current.positionAfterSkippingLeadingTrivia] {
                case .allowed?:
                    // colon has padding, and is allowed to have it
                    text += "\(current)"
                case .ternary?:
                    fallthrough

                case .disallowed?:
                    // colon has padding, that may need to be collapsed
                    var trailingTrivia: String = "\(current.trailingTrivia)"
                    while case " "? = trailingTrivia.last {
                        trailingTrivia.removeLast()
                    }

                    text += "\(current.with(\.trailingTrivia, []))"
                    text.append(" ")


                case nil:
                    fatalError(
                        "unmarked colon at [\(current.positionAfterSkippingLeadingTrivia)]"
                    )
                }
            } else {
                text += "\(current)"
            }
        }

        return text
    }
}
