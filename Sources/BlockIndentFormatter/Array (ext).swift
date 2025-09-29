import Swift

extension [Unicode.Scalar] {
    /// Decodes a string containing Swift literal escape sequences.
    ///
    /// - Returns: A new string with all valid escape sequences properly interpreted.
    static func decode(literal: String) -> Self {
        return .init(literal: literal.unicodeScalars)
    }

    private init(literal: borrowing String.UnicodeScalarView) {
        self.init()
        self.reserveCapacity(literal.count)

        var i: String.Index = literal.startIndex
        while i < literal.endIndex {
            let character: Unicode.Scalar = literal[i]
            if  character != "\\" {
                // regular character, not an escape sequence
                i = literal.index(after: i)
                self.append(character)
                continue
            }

            let j: String.Index = literal.index(after: i)

            guard j < literal.endIndex else {
                // malformed literal, ends with a single '\'
                self.append(character)
                break
            }

            let k: String.Index = literal.index(after: j)

            escape:
            if  let character: Unicode.Scalar = Self.decode(escape: literal[j]) {
                self.append(character)
                i = k
                continue
            } else if literal[j] == "u", k < literal.endIndex, literal[k] == "{" {
                let hex: String.Index = literal.index(after: k)
                guard
                let end: String.Index = literal[hex...].firstIndex(of: "}"),
                let value: UInt32 = .init(String.init(literal[hex ..< end]), radix: 16),
                let scalar: Unicode.Scalar = .init(value) else {
                    break escape
                }

                i = literal.index(after: end)
                self.append(scalar)
                continue
            }

            // not a recognized escape sequence, just append the two characters
            // and continue processing from the next character
            self.append(character)
            self.append(literal[j])
            i = k
        }
    }

    private static func decode(escape code: Unicode.Scalar) -> Unicode.Scalar? {
        switch code {
        case "n": "\n"
        case "r": "\r"
        case "t": "\t"
        case "\\": "\\"
        case "\"": "\""
        case "'": "'"
        case "0": "\0"
        default: nil
        }
    }
}
