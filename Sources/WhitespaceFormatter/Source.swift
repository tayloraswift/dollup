import SwiftOperators
import SwiftParser
import SwiftSyntax

struct Source: ~Copyable {
    private let operators: OperatorTable
    private(set) var text: String
    private(set) var tree: Syntax

    private init(operators: OperatorTable, text: String, tree: Syntax) {
        self.operators = operators
        self.text = text
        self.tree = tree
    }
}
extension Source {
    init(operators: OperatorTable, text: String) {
        self.operators = operators
        self.text = text
        self.tree = Self.parse(operators: self.operators, text: self.text)
    }

    static func parse(operators: OperatorTable, text: String) -> Syntax {
        operators.foldAll(Parser.parse(source: text)) {
            print("operator folding error: \($0)")
        }
    }
}
extension Source {
    mutating func update(text: consuming String) {
        self.update(text: text, didChange: !self.text.utf8.elementsEqual(text.utf8))
    }
    mutating func update(text: consuming String, didChange: Bool) {
        self.text = text
        if  didChange {
            self.tree = Self.parse(operators: self.operators, text: self.text)
        }
    }
    mutating func update(with text: consuming String, onChange: (consuming String) -> String) {
        if !self.text.utf8.elementsEqual(text.utf8) {
            self.update(text: onChange(text), didChange: true)
        }
    }
}
