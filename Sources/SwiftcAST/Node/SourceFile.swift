public final class SourceFile : ASTContextNode
{
    public var parentContext: ASTContextNode? { nil }
    public var statements: [ASTNode] = []
    
    public init() {
    }
}
