import SwiftSyntax

public final class ClosureExpr : ASTNodeBase {
    public var parameter: VariableDecl
    public var expression: ASTNode
    
    public init(parameter: VariableDecl,
                expression: ASTNode,
                sourceRange: Range<AbsolutePosition>?)
    {
        self.parameter = parameter
        self.expression = expression
        super.init(sourceRange: sourceRange)
    }
}
