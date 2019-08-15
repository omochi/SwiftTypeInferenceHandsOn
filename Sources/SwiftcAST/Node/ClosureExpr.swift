public final class ClosureExpr : ASTContextNode {
    public weak var parentContext: ASTContextNode?
    public var parameter: VariableDecl
    public var body: [ASTNode] = []
    
    public init(parentContext: ASTContextNode?,
                parameter: VariableDecl)
    {
        self.parentContext = parentContext
        self.parameter = parameter
    }
}
