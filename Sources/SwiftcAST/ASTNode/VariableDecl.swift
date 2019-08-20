import SwiftcType

public final class VariableDecl : ASTNode {
    public var name: String
    public var initializer: ASTExprNode?
    public var typeAnnotation: Type?
    public var type: Type?
    public init(name: String,
                initializer: ASTExprNode?,
                typeAnnotation: Type?)
    {
        self.name = name
        self.initializer = initializer
        self.typeAnnotation = typeAnnotation
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitVariableDecl(self)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTFailableVisitor {
        try visitor.visitVariableDecl(self)
    }
}
