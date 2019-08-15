public protocol ASTContextNode : ASTNode {
    var parentContext: ASTContextNode? { get }
}
