public protocol ASTContextNode : ASTNode {
    var parentContext: ASTContextNode? { get }
    
    func resolve(name: String) -> ASTNode?
}
