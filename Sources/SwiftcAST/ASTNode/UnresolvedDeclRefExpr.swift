import SwiftcType

public final class UnresolvedDeclRefExpr : ASTExprNode {
    public var name: String
    
    public var type: Type?
    
    public init(name: String) {
        self.name = name
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitUnresolvedDeclRefExpr(self)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTFailableVisitor {
        try visitor.visitUnresolvedDeclRefExpr(self)
    }
}
