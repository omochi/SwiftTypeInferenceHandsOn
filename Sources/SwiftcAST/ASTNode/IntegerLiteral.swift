import SwiftcType

public final class IntegerLiteralExpr : ASTExprNode {
    public var type: Type?
    
    public init() {
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitIntegerLiteralExpr(self)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTFailableVisitor {
        try visitor.visitIntegerLiteralExpr(self)
    }
}
