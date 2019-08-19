import SwiftcBasic
import SwiftcAST

public final class TypeChecker {
    private let source: SourceFile
    
    public init(source: SourceFile) {
        self.source = source
    }
    
    public func typeCheck() throws {
        try resolveDeclRef()
    }
    
    public func resolveDeclRef() throws {
        var error: Error?
        
        func tr(node: ASTNode, context: ASTContextNode?) -> ASTNode? {
            if let _ = error { return nil }
            
            switch node {
            case let node as UnresolvedDeclRefExpr:
                guard let context = context else {
                    error = MessageError("no context in resolving")
                    return nil
                }
                
                let name = node.name
                
                guard let target = context.resolve(name: name) else {
                    error = MessageError("failed to resolve: \(name)")
                    return nil
                }

                return DeclRefExpr(name: name, target: target)
            default:
                return nil
            }
        }
        
        _ = source.transformExpr(context: nil, tr)
        
        if let error = error {
            throw error
        }
    }
}
