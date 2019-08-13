import SwiftSyntax

public final class CallExpr : ASTNodeBase {
    public var callee: ASTNode
    public var argument: ASTNode
    public init(callee: ASTNode,
                argument: ASTNode,
                sourceRange: Range<AbsolutePosition>?)
    {
        self.callee = callee
        self.argument = argument
        super.init(sourceRange: sourceRange)
    }
}
