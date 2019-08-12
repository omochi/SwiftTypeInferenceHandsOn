public final class ClosureExpr : ASTNode {
    public var parameter: VariableDecl
    public var expression: ASTNode
    
    public init(parameter: VariableDecl,
                expression: ASTNode)
    {
        self.parameter = parameter
        self.expression = expression
    }
}
