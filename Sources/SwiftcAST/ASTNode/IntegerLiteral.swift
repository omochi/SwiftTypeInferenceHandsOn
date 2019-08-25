import SwiftcType

public final class IntegerLiteralExpr : ASTExprNode {
    public var type: Type?
    
    public init() {
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitIntegerLiteralExpr(self)
    }
}
