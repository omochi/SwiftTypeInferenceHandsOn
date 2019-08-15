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
}
