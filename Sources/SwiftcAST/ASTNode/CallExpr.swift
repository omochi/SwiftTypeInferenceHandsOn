import SwiftcType

public final class CallExpr : ASTExprNode {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public var callee: ASTNode
    public var argument: ASTNode
    public var type: Type?
    public init(source: SourceFile,
                sourceRange: SourceRange,
                callee: ASTNode,
                argument: ASTNode)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.callee = callee
        self.argument = argument
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitCallExpr(self)
    }
}
