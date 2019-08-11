import SwiftcType

public final class FunctionDecl : ASTNode {
    public var name: String
    
    public var parameterType: Type
    public var resultType: Type
    
    public init(name: String,
                parameterType: Type,
                resultType: Type)
    {
        self.name = name
        self.parameterType = parameterType
        self.resultType = resultType
    }
}
