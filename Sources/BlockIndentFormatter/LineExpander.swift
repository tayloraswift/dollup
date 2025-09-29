import SwiftSyntax

class LineExpander: SyntaxVisitor {
    private(set) var linebreaks: [Linebreak]
    /// The original source text, used for measuring line lengths.
    private let text: String

    init(text: String, width: Int) {
        self.linebreaks = []
        self.text = text
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: ArrayExprSyntax) -> SyntaxVisitorContinueKind {
        if !node.elements.isEmpty, node.containsInteriorNewlines {
            if  node.elements.lacksPrecedingNewline {
                self.break(before: node.elements)
            }
            if  node.rightSquare.lacksPrecedingNewline {
                self.break(before: node.rightSquare)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: DictionaryExprSyntax) -> SyntaxVisitorContinueKind {
        if  case .elements(let elements) = node.content, node.containsInteriorNewlines {
            if  elements.lacksPrecedingNewline {
                self.break(before: elements)
            }
            if  node.rightSquare.lacksPrecedingNewline {
                self.break(before: node.rightSquare)
            }
        }
        return .visitChildren
    }

    override func visit(_ node: TupleExprSyntax) -> SyntaxVisitorContinueKind {
        if !node.elements.isEmpty, node.containsInteriorNewlines {
            if  node.elements.lacksPrecedingNewline {
                self.break(before: node.elements)
            }
            if  node.rightParen.lacksPrecedingNewline {
                self.break(before: node.rightParen)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: TuplePatternSyntax) -> SyntaxVisitorContinueKind {
        if !node.elements.isEmpty, node.containsInteriorNewlines {
            if  node.elements.lacksPrecedingNewline {
                self.break(before: node.elements)
            }
            if  node.rightParen.lacksPrecedingNewline {
                self.break(before: node.rightParen)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        if !node.elements.isEmpty, node.containsInteriorNewlines,
            let first: TupleTypeElementSyntax = node.elements.first {
            if  first.lacksPrecedingNewline {
                self.break(before: first)
            }
            if  node.rightParen.lacksPrecedingNewline {
                self.break(before: node.rightParen)
            }
        }
        return .visitChildren
    }

    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        if  let arguments: AttributeSyntax.Arguments = node.arguments,
            let rightParen: TokenSyntax = node.rightParen,
            node.containsInteriorNewlines {
            if  arguments.lacksPrecedingNewline {
                self.break(before: arguments)
            }
            if  rightParen.lacksPrecedingNewline {
                self.break(before: rightParen)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: ClosureParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        if !node.parameters.isEmpty, node.containsInteriorNewlines {
            if  node.parameters.lacksPrecedingNewline {
                self.break(before: node.parameters)
            }
            if  node.rightParen.lacksPrecedingNewline {
                self.break(before: node.rightParen)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: EnumCaseParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        if !node.parameters.isEmpty, node.containsInteriorNewlines {
            if  node.parameters.lacksPrecedingNewline {
                self.break(before: node.parameters)
            }
            if  node.rightParen.lacksPrecedingNewline {
                self.break(before: node.rightParen)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: FunctionParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        if !node.parameters.isEmpty, node.containsInteriorNewlines {
            if  node.parameters.lacksPrecedingNewline {
                self.break(before: node.parameters)
            }
            if  node.rightParen.lacksPrecedingNewline {
                self.break(before: node.rightParen)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if !node.arguments.isEmpty,
            let leftParen: TokenSyntax = node.leftParen,
            let rightParen: TokenSyntax = node.rightParen,
            node.arguments.containsInteriorNewlines(between: (leftParen, rightParen)) {
            if  node.arguments.lacksPrecedingNewline {
                self.break(before: node.arguments)
            }
            if  rightParen.lacksPrecedingNewline {
                self.break(before: rightParen)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: MacroExpansionExprSyntax) -> SyntaxVisitorContinueKind {
        if !node.arguments.isEmpty,
            let leftParen: TokenSyntax = node.leftParen,
            let rightParen: TokenSyntax = node.rightParen,
            node.containsInteriorNewlines(between: (leftParen, rightParen)) {
            if  node.arguments.lacksPrecedingNewline {
                self.break(before: node.arguments)
            }
            if  rightParen.lacksPrecedingNewline {
                self.break(before: rightParen)
            }
        }
        return .visitChildren
    }

    override func visit(_ node: GenericArgumentClauseSyntax) -> SyntaxVisitorContinueKind {
        if !node.arguments.isEmpty, node.containsInteriorNewlines {
            if  node.arguments.lacksPrecedingNewline {
                self.break(before: node.arguments)
            }
            if  node.rightAngle.lacksPrecedingNewline {
                self.break(before: node.rightAngle)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: GenericParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        if !node.parameters.isEmpty, node.containsInteriorNewlines {
            if  node.parameters.lacksPrecedingNewline {
                self.break(before: node.parameters)
            }
            if  node.rightAngle.lacksPrecedingNewline {
                self.break(before: node.rightAngle)
            }
        }
        return .visitChildren
    }
    override func visit(_ node: PrimaryAssociatedTypeClauseSyntax) -> SyntaxVisitorContinueKind {
        if !node.primaryAssociatedTypes.isEmpty, node.containsInteriorNewlines {
            if  node.primaryAssociatedTypes.lacksPrecedingNewline {
                self.break(before: node.primaryAssociatedTypes)
            }
            if  node.rightAngle.lacksPrecedingNewline {
                self.break(before: node.rightAngle)
            }
        }
        return .visitChildren
    }
}
extension LineExpander {
    private func walkIfPresent<Node>(_ node: Node?) where Node: SyntaxProtocol {
        if  let node: Node {
            self.walk(node)
        }
    }
}
extension LineExpander {
    private func `break`(before node: some SyntaxProtocol, type: LinebreakType = .newline) {
        /// Line break position is after any leading trivia.
        let position: String.Index = self.text.utf8.index(
            self.text.utf8.startIndex,
            offsetBy: node.positionAfterSkippingLeadingTrivia.utf8Offset
        )
        self.linebreaks.append(.init(index: position, type: type))
    }
}
