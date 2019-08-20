import SwiftcType

public final class SourceFile : ASTContextNode {
    public var parentContext: ASTContextNode? { nil }
    public var statements: [ASTNode] = []
    
    public init() {
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : ASTVisitor {
        visitor.visitSourceFile(self)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTFailableVisitor {
        try visitor.visitSourceFile(self)
    }
    
    public func addStatement(_ st: ASTNode) {
        statements.append(st)
    }
    
    public var interfaceType: Type? { nil }
    
    public func resolve(name: String) -> ASTNode? {
        // TOOD: consider statement order
        
        if let fn = (statements.first { self.name(for: $0) == name }) {
            return fn
        }
        
        return nil
    }
    
    private func name(for statement: ASTNode) -> String? {
        switch statement {
        case let d as VariableDecl: return d.name
        case let d as FunctionDecl: return d.name
        default: return nil
        }
    }
}
