import SwiftcType

public final class InjectIntoOptionalExpr : Expr {
    public var source: SourceFile { subExpr.source }
    public var sourceRange: SourceRange { subExpr.sourceRange }
    public var type: Type?
    public var subExpr: Expr
    
    public init(subExpr: Expr,
                type: Type)
    {
        self.subExpr = subExpr
        self.type = type
    }
    
    public var descriptionPartsTail: [String] { Exprs.descriptionParts(self) }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visit(self)
    }
}
