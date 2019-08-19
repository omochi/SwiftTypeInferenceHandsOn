public final class IntegerLiteralExpr : ASTNode {
    public init() {
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitIntegerLiteralExpr(self)
    }
}
