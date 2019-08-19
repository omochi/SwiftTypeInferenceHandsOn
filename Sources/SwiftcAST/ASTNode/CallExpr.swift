public final class CallExpr : ASTNode {
    public var callee: ASTNode
    public var argument: ASTNode
    public init(callee: ASTNode,
                argument: ASTNode)
    {
        self.callee = callee
        self.argument = argument
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitCallExpr(self)
    }    
}
