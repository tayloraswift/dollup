import SwiftSyntax

public struct FoldAttributesOptions {
    public var _alignment: Bool = true
    public var _alwaysEmitIntoClient: Bool = true
    public var attached: Bool = false
    public var available: Bool = false
    public var backDeployed: Bool = false
    public var _cdecl: Bool = false
    public var discardableResult: Bool = false
    public var _disfavoredOverload: Bool = false
    public var _documentation: Bool = false
    public var dynamicCallable: Bool = true
    public var dynamicMemberLookup: Bool = true
    public var _effects: Bool = true
    public var _exported: Bool = true
    public var freestanding: Bool = false
    public var frozen: Bool = true
    public var globalActor: Bool = true
    public var _hasStorage: Bool = true
    public var _implements: Bool = false
    public var _implementationOnly: Bool = true
    public var inlinable: Bool = true
    public var inline: Bool = true
    public var nonobjc: Bool = true
    public var _nonSendable: Bool = true
    public var main: Bool = true
    public var _marker: Bool = true
    public var objc: Bool = true
    public var objcMembers: Bool = true
    public var _optimize: Bool = true
    public var preconcurrency: Bool = true
    public var propertyWrapper: Bool = true
    public var resultBuilder: Bool = true
    public var _semantics: Bool = false
    public var _silgen_name: Bool = false
    public var _specialize: Bool = false
    public var _spi: Bool = true
    public var testable: Bool = true
    public var _transparent: Bool = true
    public var usableFromInline: Bool = true
    public var _weakLinked: Bool = true

    @available(*, unavailable, message: "@autoclosure is never foldable")
    public var autoclosure: Bool { false }
    @available(*, unavailable, message: "@convention is never foldable")
    public var convention: Bool { false }
    @available(*, unavailable, message: "@escaping is never foldable")
    public var escaping: Bool { false }
    @available(*, unavailable, message: "@unchecked is never foldable")
    public var unchecked: Bool { false }
    @available(*, unavailable, message: "@unknown is never foldable")
    public var unknown: Bool { false }

    public var allOthers: DefaultBehavior = .nameOnly

    public init() {}
}
extension FoldAttributesOptions {
    func fold(_ node: AttributeSyntax) -> Bool {
        guard
        let name: TokenSyntax = node.attributeName.as(IdentifierTypeSyntax.self)?.name else {
            return false
        }

        switch name.text {
        case "_alignment": return self._alignment
        case "_alwaysEmitIntoClient": return self._alwaysEmitIntoClient
        case "attached": return self.attached
        case "available": return self.available
        case "backDeployed": return self.backDeployed
        case "_cdecl": return self._cdecl
        case "discardableResult": return self.discardableResult
        case "_disfavoredOverload": return self._disfavoredOverload
        case "_documentation": return self._documentation
        case "dynamicCallable": return self.dynamicCallable
        case "dynamicMemberLookup": return self.dynamicMemberLookup
        case "_effects": return self._effects
        case "_exported": return self._exported
        case "freestanding": return self.freestanding
        case "frozen": return self.frozen
        case "globalActor": return self.globalActor
        case "_hasStorage": return self._hasStorage
        case "_implements": return self._implements
        case "_implementationOnly": return self._implementationOnly
        case "inlinable": return self.inlinable
        case "inline": return self.inline
        case "nonobjc": return self.nonobjc
        case "_nonSendable": return self._nonSendable
        case "main": return self.main
        case "_marker": return self._marker
        case "objc": return self.objc
        case "objcMembers": return self.objcMembers
        case "_optimize": return self._optimize
        case "preconcurrency": return self.preconcurrency
        case "propertyWrapper": return self.propertyWrapper
        case "resultBuilder": return self.resultBuilder
        case "_semantics": return self._semantics
        case "_silgen_name": return self._silgen_name
        case "_specialize": return self._specialize
        case "_spi": return self._spi
        case "testable": return self.testable
        case "_transparent": return self._transparent
        case "usableFromInline": return self.usableFromInline
        case "_weakLinked": return self._weakLinked
        default: break
        }

        switch self.allOthers {
        case .always:
            return true

        case .nameOnly:
            if case .argumentList(let arguments)? = node.arguments {
                return arguments.isEmpty
            } else {
                return true
            }

        case .never:
            return false
        }
    }
}
