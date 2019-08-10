import SwiftSyntax

public struct SyntaxTypePair {
    public var syntax: Syntax
    public var type: Type
}

public typealias SyntaxTypeMap = [SyntaxIdentifier: SyntaxTypePair]
