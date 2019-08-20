import SwiftcType

public protocol ASTContextNode : ASTNode {
    var parentContext: ASTContextNode? { get }
    
    var interfaceType: Type? { get }
    
    func resolve(name: String) -> ASTNode?
}
