import SwiftcBasic
import SwiftcType

public final class OptionalEvaluationExpr : Expr {
    public var type: Type?
    public var subExpr: Expr
    
    public var source: SourceFile { subExpr.source }
    
    public var sourceRange: SourceRange { subExpr.sourceRange }
    
    public init(subExpr: Expr,
                type: Type) {
        self.subExpr = subExpr
        self.type = type
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visit(self)
    }
    
    public var descriptionPartsTail: [String] { Exprs.descriptionParts(self) }
}
