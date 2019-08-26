import SwiftcType

public final class SourceFile : Decl {
    public var parentContext: DeclContext? { nil }
    public var statements: [ASTNode] = []
    public var ownedNodes: [ASTNode] = []
    
    public init() {
    }
    
    public func dispose() {
        for node in ownedNodes {
            node.dispose()
        }
        ownedNodes.removeAll()
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitSourceFile(self)
    }
    
    public func addStatement(_ st: ASTNode) {
        statements.append(st)
    }
    
    public var interfaceType: Type? { nil }
    
    public func resolveInSelf(name: String) -> [ValueDecl] {
        statements.compactMap { $0 as? ValueDecl }
            .filter { $0.name == name }
    }
}
