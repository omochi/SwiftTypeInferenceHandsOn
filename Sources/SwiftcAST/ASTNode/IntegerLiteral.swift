import SwiftcType

public final class IntegerLiteralExpr : ASTExprNode {
    public let sourceRange: SourceRange
    public var type: Type?
    
    public init(sourceRange: SourceRange) {
        self.sourceRange = sourceRange
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitIntegerLiteralExpr(self)
    }
}
