import SwiftcType

public final class InjectIntoOptionalExpr : Expr {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public var type: Type?
    public var subExpr: Expr
    
    public init(source: SourceFile,
                sourceRange: SourceRange,
                subExpr: Expr)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.subExpr = subExpr
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitInjectIntoOptionalExpr(self)
    }
}
