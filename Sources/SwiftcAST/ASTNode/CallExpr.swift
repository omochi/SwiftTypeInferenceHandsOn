import SwiftcType

public final class CallExpr : ASTExprNode {
    public var callee: ASTNode
    public var argument: ASTNode
    public var type: Type?
    public init(callee: ASTNode,
                argument: ASTNode)
    {
        self.callee = callee
        self.argument = argument
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitCallExpr(self)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTFailableVisitor {
        try visitor.visitCallExpr(self)
    }
}
