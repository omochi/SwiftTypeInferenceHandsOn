import SwiftSyntax
import SwiftcType

public final class VariableDecl : ASTNodeBase {
    public var name: String
    public var initializer: ASTNode?
    public var typeAnnotation: Type?
    
    public init(name: String,
                initializer: ASTNode?,
                typeAnnotation: Type?,
                sourceRange: Range<AbsolutePosition>?)
    {
        self.name = name
        self.initializer = initializer
        self.typeAnnotation = typeAnnotation
        super.init(sourceRange: sourceRange)
    }
}
