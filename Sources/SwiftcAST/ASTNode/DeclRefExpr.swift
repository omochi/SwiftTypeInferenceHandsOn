import SwiftcType

public final class DeclRefExpr : ASTExprNode {
    public var name: String
    public unowned var target: ASTNode
    public var type: Type?
    
    public init(name: String,
                target: ASTNode)
    {
        self.name = name
        self.target = target
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitDeclRefExpr(self)
    }
}
