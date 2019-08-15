import SwiftcAST

public final class TypeChecker {
    private let source: SourceFile
    
    public init(source: SourceFile) {
        self.source = source
    }
    
    public func typeCheck() {
        resolveDeclRef()
    }
    
    public func resolveDeclRef() {
        func tr(node: ASTNode, context: ASTContextNode?) -> ASTNode? {
            nil
        }
        
        _ = source.transformExpr(context: nil, tr)
    }
}
