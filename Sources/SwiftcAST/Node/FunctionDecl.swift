import SwiftSyntax
import SwiftcType

public final class FunctionDecl : ASTNodeBase {
    public var name: String
    public var parameterType: Type
    public var resultType: Type
    
    public init(name: String,
                parameterType: Type,
                resultType: Type,
                sourceRange: Range<AbsolutePosition>?)
    {
        self.name = name
        self.parameterType = parameterType
        self.resultType = resultType
        super.init(sourceRange: sourceRange)
    }
}
