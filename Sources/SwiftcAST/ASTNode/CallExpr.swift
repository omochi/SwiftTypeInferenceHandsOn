import SwiftcType

public final class CallExpr : ASTExprNode {
    public let sourceRange: SourceRange
    public var callee: ASTNode
    public var argument: ASTNode
    public var type: Type?
    public init(sourceRange: SourceRange,
                callee: ASTNode,
                argument: ASTNode)
    {
        self.sourceRange = sourceRange
        self.callee = callee
        self.argument = argument
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitCallExpr(self)
    }
}
