import SwiftcType

public final class ClosureExpr : ASTContextNode, ASTExprNode {
    public weak var parentContext: ASTContextNode?
    public var parameter: VariableDecl
    public var body: [ASTNode] = []
    public var type: Type?
    
    public init(parentContext: ASTContextNode?,
                parameter: VariableDecl)
    {
        self.parentContext = parentContext
        self.parameter = parameter
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitClosureExpr(self)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTFailableVisitor {
        try visitor.visitClosureExpr(self)
    }
    
    public var interfaceType: Type? { type }
    
    public func resolve(name: String) -> ASTNode? {
        if parameter.name == name {
            return parameter
        }
        
        return nil
    }
}
