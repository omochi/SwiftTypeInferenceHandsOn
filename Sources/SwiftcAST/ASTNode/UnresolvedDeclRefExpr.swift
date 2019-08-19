public final class UnresolvedDeclRefExpr : ASTNode {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitUnresolvedDeclRefExpr(self)
    }
}
