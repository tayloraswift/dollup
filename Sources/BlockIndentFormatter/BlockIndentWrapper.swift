import SwiftSyntax
import SwiftParser

class BlockIndentWrapper: SyntaxVisitor {
    private(set) var linebreaks: [String.Index]
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
        let leftParen: TokenSyntax = node.leftParen,
        let rightParen: TokenSyntax = node.rightParen else {
            // visit children to find breakable closures, worst case we just waste some time
            return .visitChildren
        }

        switch self.limitViolated(by: node) {
        case nil: return .visitChildren
        case true?: break
        case false?: return .skipChildren
        }

        self.break(after: leftParen)
        for parameter: LabeledExprSyntax in node.arguments {
            self.break(after: parameter)
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

    private func `break`(before node: some SyntaxProtocol) {
        /// Line break position is after any leading trivia.
        let position: String.Index = self.text.utf8.index(
            self.text.utf8.startIndex,
            offsetBy: node.positionAfterSkippingLeadingTrivia.utf8Offset
        )
        self.linebreaks.append(position)
    }
    private func `break`(after node: some SyntaxProtocol) {
        /// Line break position is after any trailing trivia, such as a trailing line comment.
        let position: String.Index = self.text.utf8.index(
            self.text.utf8.startIndex,
            offsetBy: node.endPosition.utf8Offset
        )
        self.linebreaks.append(position)
    }
}
