import SwiftcType

public final class OverloadedDeclRefExpr : ASTExprNode {
    public let sourceRange: SourceRange
    public var name: String
    public var targets: [ValueDecl]
    public var type: Type?
    
    public init(sourceRange: SourceRange,
                name: String,
                targets: [ValueDecl],
                source: SourceFile)
    {
        self.sourceRange = sourceRange
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
