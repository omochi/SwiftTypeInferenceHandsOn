import SwiftcType

public final class VariableDecl : ASTNode {
    public var name: String
    public var initializer: ASTNode?
    public var typeAnnotation: Type?
    
    public init(name: String,
                initializer: ASTNode?,
                typeAnnotation: Type?)
    {
        self.name = name
        self.initializer = initializer
        self.typeAnnotation = typeAnnotation
    }
}
