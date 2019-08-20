import SwiftcType

public final class FunctionDecl : ASTContextNode {
    public weak var parentContext: ASTContextNode?
    public var name: String
    public var parameterType: Type
    public var resultType: Type
    public init(parentContext: ASTContextNode?,
                name: String,
                parameterType: Type,
                resultType: Type)
    {
        self.parentContext = parentContext
        self.name = name
        self.parameterType = parameterType
        self.resultType = resultType
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitFunctionDecl(self)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTFailableVisitor {
        try visitor.visitFunctionDecl(self)
    }
    
    public var interfaceType: Type? {
        FunctionType(parameter: parameterType, result: resultType)
    }
    
    public func resolve(name: String) -> ASTNode? {
        // TODO: support parameters
        if self.name == name {
            return self
        }
        
        return nil
    }
}
