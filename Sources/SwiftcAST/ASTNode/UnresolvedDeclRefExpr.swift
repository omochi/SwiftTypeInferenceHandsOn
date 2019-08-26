import SwiftcType

public final class UnresolvedDeclRefExpr : ASTExprNode {
    public let sourceRange: SourceRange
    public var name: String
    public var type: Type?
    
    public init(sourceRange: SourceRange,
                name: String)
    {
        self.sourceRange = sourceRange
        self.name = name
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitUnresolvedDeclRefExpr(self)
    }
}
