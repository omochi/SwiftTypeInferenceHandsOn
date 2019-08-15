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
    
    public func replaceBody(old: ASTNode, new: ASTNode) {
        guard old !== new else { return }
        
        if let index = (body.firstIndex { $0 === old }) {
            body[index] = new
        }
    }
}
