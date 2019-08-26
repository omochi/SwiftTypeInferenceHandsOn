import SwiftcType

public final class DeclRefExpr : ASTExprNode {
    public let sourceRange: SourceRange
    public var name: String
    public var target: ValueDecl!
    public var type: Type?
    
    public init(sourceRange: SourceRange,
                name: String,
                target: ValueDecl,
                source: SourceFile)
    {
        self.sourceRange = sourceRange
        self.name = name
        self.target = target
        source.ownedNodes.append(self)
    }
    
    public func dispose() {
        target = nil
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitDeclRefExpr(self)
    }
}
