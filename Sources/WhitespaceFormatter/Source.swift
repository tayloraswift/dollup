import SwiftOperators
import SwiftParser
import SwiftSyntax

struct Source: ~Copyable {
    private let operators: OperatorTable
    private(set) var text: String
    private(set) var tree: Syntax
    private(set) var operatorsNotRecognized: [OperatorError]

    private init(operators: OperatorTable, text: String, tree: Syntax) {
        self.operators = operators
        self.text = text
        self.tree = tree
        self.operatorsNotRecognized = []
    }
}
extension Source {
    init(operators: OperatorTable, text: String) {
        self.operators = operators
        self.text = text
        (self.tree, self.operatorsNotRecognized) = Self.parse(
            operators: self.operators,
            text: self.text
        )
    }

    mutating func reparse() {
        (self.tree, self.operatorsNotRecognized) = Self.parse(
            operators: self.operators,
            text: self.text
        )
    }

    static func parse(operators: OperatorTable, text: String) -> (Syntax, [OperatorError]) {
        var operatorsNotRecognized: [OperatorError] = []
        let syntax: Syntax = operators.foldAll(Parser.parse(source: text)) {
            operatorsNotRecognized.append($0)
        }
        return (syntax, operatorsNotRecognized)
    }
}
extension Source {
    mutating func update(text: consuming String) {
        self.update(text: text, didChange: !self.text.utf8.elementsEqual(text.utf8))
    }
    mutating func update(text: consuming String, didChange: Bool) {
        self.text = text
        if  didChange {
            self.reparse()
        }
    }
    mutating func update(with text: consuming String, onChange: (consuming String) -> String) {
        if !self.text.utf8.elementsEqual(text.utf8) {
            self.update(text: onChange(text), didChange: true)
        }
    }
}
