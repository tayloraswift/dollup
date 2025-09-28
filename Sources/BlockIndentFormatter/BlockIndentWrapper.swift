import SwiftSyntax
import SwiftParser

class BlockIndentWrapper: SyntaxVisitor {
    private(set) var linebreaks: [Linebreak]
    /// The original source text, used for measuring line lengths.
    private let text: String
    private var dirty: String.Index?

    private let width: Int

    init(text: String, width: Int) {
        self.linebreaks = []
        self.text = text
        self.dirty = nil

        self.width = width
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: AccessorBlockSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftBrace)
        self.break(before: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftBrace)
        self.break(before: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: MemberBlockSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftBrace)
        self.break(before: node.rightBrace)
        return .skipChildren
    }
    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        if  let signature: ClosureSignatureSyntax = node.signature {
            self.break(after: signature)
        } else {
            self.break(after: node.leftBrace)
        }

        self.break(before: node.rightBrace)
        return .skipChildren
    }

    override func visit(_ node: ArrayExprSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftSquare)
        for element: ArrayElementSyntax in node.elements {
            self.break(after: element)
        }
        return .skipChildren
    }
    override func visit(_ node: DictionaryExprSyntax) -> SyntaxVisitorContinueKind {
        guard case .elements(let elements) = node.content else {
            // we cannot line wrap a `[:]` dictionary literal
            return .skipChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftSquare)
        for element: DictionaryElementSyntax in elements {
            self.break(after: element)
        }
        return .skipChildren
    }

    override func visit(_ node: TupleExprSyntax) -> SyntaxVisitorContinueKind {
        if node.elements.isEmpty {
            // we cannot line wrap an empty tuple `()` (well we could, but it would be weird)
            return .skipChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftParen)
        for element: LabeledExprSyntax in node.elements {
            self.break(after: element)
        }
        return .skipChildren
    }
    override func visit(_ node: TuplePatternSyntax) -> SyntaxVisitorContinueKind {
        if node.elements.isEmpty {
            // yes, it’s actually valid Swift, although not very useful
            return .skipChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftParen)
        for element: TuplePatternElementSyntax in node.elements {
            self.break(after: element)
        }
        return .skipChildren
    }
    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        if node.elements.isEmpty {
            return .skipChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftParen)
        for element: TupleTypeElementSyntax in node.elements {
            self.break(after: element)
        }
        return .skipChildren
    }

    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        guard
        let leftParen: TokenSyntax = node.leftParen,
        let arguments: AttributeSyntax.Arguments = node.arguments else {
            // perhaps there is something breakable inside the attribute type
            return .visitChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: leftParen)
        switch arguments {
        case .abiArguments(let arguments):
            self.break(after: arguments.provider)
        case .argumentList(let arguments):
            for argument: LabeledExprSyntax in arguments {
                self.break(after: argument)
            }
        case .availability(let arguments):
            for argument: AvailabilityArgumentSyntax in arguments {
                self.break(after: argument)
            }
        case .documentationArguments(let arguments):
            for argument: DocumentationAttributeArgumentSyntax in arguments {
                self.break(after: argument)
            }
        case .specializeArguments(let arguments):
            for argument: SpecializeAttributeArgumentListSyntax.Element in arguments {
                self.break(after: argument)
            }
        case .backDeployedArguments(let arguments):
            self.break(after: arguments)
        case .effectsArguments(let arguments):
            self.break(after: arguments)
        case .dynamicReplacementArguments(let arguments):
            self.break(after: arguments)
        case .implementsArguments(let arguments):
            self.break(after: arguments)
        case .differentiableArguments(let arguments):
            self.break(after: arguments)
        case .derivativeRegistrationArguments(let arguments):
            self.break(after: arguments)
        case .objCName(let arguments):
            self.break(after: arguments)
        case .originallyDefinedInArguments(let arguments):
            self.break(after: arguments)
        }

        return .skipChildren
    }
    override func visit(_ node: ClosureParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        if node.parameters.isEmpty {
            return .skipChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftParen)
        for parameter: ClosureParameterSyntax in node.parameters {
            self.break(after: parameter)
        }
        return .skipChildren
    }
    override func visit(_ node: EnumCaseParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftParen)
        for parameter: EnumCaseParameterSyntax in node.parameters {
            self.break(after: parameter)
        }
        return .skipChildren
    }
    override func visit(_ node: FunctionParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        if node.parameters.isEmpty {
            return .skipChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftParen)
        for parameter: FunctionParameterSyntax in node.parameters {
            self.break(after: parameter)
        }
        return .skipChildren
    }
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard !node.arguments.isEmpty,
        let leftParen: TokenSyntax = node.leftParen else {
            // visit children to find breakable closures, worst case we just waste some time
            return .visitChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        // if there are single line trailing closures, we want to try breaking those first,
        // in case that allows us to not have to break the argument list
        if  let first: ClosureExprSyntax = node.trailingClosure {
            self.break(closure: first)
            for next: MultipleTrailingClosureElementSyntax in node.additionalTrailingClosures {
                self.break(closure: next.closure)
            }
        } else {
            self.break(after: leftParen)
            for parameter: LabeledExprSyntax in node.arguments {
                self.break(after: parameter)
            }
        }

        return .skipChildren
    }

    override func visit(_ node: GenericArgumentClauseSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftAngle)
        for argument: GenericArgumentSyntax in node.arguments {
            self.break(after: argument)
        }
        return .skipChildren
    }
    override func visit(_ node: GenericParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftAngle)
        for parameter: GenericParameterSyntax in node.parameters {
            self.break(after: parameter)
        }
        return .skipChildren
    }
    override func visit(_ node: PrimaryAssociatedTypeClauseSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.leftAngle)
        for type: PrimaryAssociatedTypeSyntax in node.primaryAssociatedTypes {
            self.break(after: type)
        }
        return .skipChildren
    }

    // `if`, `for`, and friends are not themselves wrappable, rather it is the
    // ``CodeBlockSyntax`` nodes inside them that are wrappable

    override func visit(_ node: SwitchCaseSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: node.label)
        return .skipChildren
    }

    override func visit(_ node: StringLiteralExprSyntax) -> SyntaxVisitorContinueKind {
        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        /// there is a dangerous line break here
        /// let x: String = "    "
        /// could become
        /// let x: String = """
        ///
        /// """
        /// which is not the same thing!

        self.break(after: node.openingQuote, type: .quotesBefore)
        self.break(before: node.closingQuote, type: .quotesAfter)
        return .skipChildren
    }
}
extension BlockIndentWrapper {
    private func walkIfPresent<Node>(_ node: Node?) where Node: SyntaxProtocol {
        if  let node: Node {
            self.walk(node)
        }
    }

    /// Returns true if the given node is fully contained within one single line, and does not
    /// fit within the specified line length limit.
    private func limitViolated(by node: some SyntaxProtocol) -> Bool? {
        let start: String.Index = self.text.utf8.index(
            self.text.utf8.startIndex,
            offsetBy: node.positionAfterSkippingLeadingTrivia.utf8Offset
        )
        let end: String.Index = self.text.utf8.index(
            self.text.utf8.startIndex,
            offsetBy: node.endPositionBeforeTrailingTrivia.utf8Offset
        )

        let characters: Int

        if  let newline: String.Index = self.text[..<end].lastIndex(where: \.isNewline) {
            if  newline > start {
                // spans multiple lines, so computing line length is not meaningful
                return nil
            }

            if case newline? = self.dirty {
                // we have already broken something on this line
                return false
            } else {
                self.dirty = newline
            }

            let start: String.Index = self.text.index(after: newline)
            characters = self.text[start..<end].count
        } else {
            // first line
            if case self.text.startIndex? = self.dirty {
                // we have already broken something on this line
                return false
            } else {
                self.dirty = self.text.startIndex
            }

            characters = self.text[..<end].count
        }

        return characters > self.width
    }

    private func `break`(closure node: ClosureExprSyntax) {
        if  let signature: ClosureSignatureSyntax = node.signature {
            self.break(after: signature)
        } else {
            self.break(after: node.leftBrace)
        }

        self.break(before: node.rightBrace)
    }
    private func `break`(before node: some SyntaxProtocol, type: LinebreakType = .newline) {
        /// Line break position is after any leading trivia.
        let position: String.Index = self.text.utf8.index(
            self.text.utf8.startIndex,
            offsetBy: node.positionAfterSkippingLeadingTrivia.utf8Offset
        )
        self.linebreaks.append(.init(index: position, type: type))
    }
    private func `break`(after node: some SyntaxProtocol, type: LinebreakType = .newline) {
        /// Line break position is after any trailing trivia, such as a trailing line comment.
        let position: String.Index = self.text.utf8.index(
            self.text.utf8.startIndex,
            offsetBy: node.endPosition.utf8Offset
        )
        self.linebreaks.append(.init(index: position, type: type))
    }
}
