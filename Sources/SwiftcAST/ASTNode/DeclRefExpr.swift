public final class DeclRefExpr : ASTNode {
    public var name: String
   
    public unowned var target: ASTNode
    
    public init(name: String,
                target: ASTNode)
    {
        self.name = name
        self.target = target
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitDeclRefExpr(self)
    }
}
