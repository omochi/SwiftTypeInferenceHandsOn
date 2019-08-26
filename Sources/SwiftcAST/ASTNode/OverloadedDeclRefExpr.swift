import SwiftcType

public final class OverloadedDeclRefExpr : ASTExprNode {
    public var name: String
    public var targets: [ValueDecl]
    public var type: Type?
    
    public init(name: String,
                targets: [ValueDecl],
                source: SourceFile)
    {
        self.name = name
        self.targets = targets
        source.ownedNodes.append(self)
    }
    
    public func dispose() {
        targets.removeAll()
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitOverloadedDeclRefExpr(self)
    }
}
