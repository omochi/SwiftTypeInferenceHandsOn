public final class SourceFile : ASTContextNode
{
    public var parentContext: ASTContextNode? { nil }
    public var statements: [ASTNode] = []
    public var functions: [FunctionDecl] = []
    public var variables: [VariableDecl] = []
    public var topLevelCodes: [ASTNode] = []
    
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
        
        switch st {
        case let fn as FunctionDecl:
            functions.append(fn)
        case let vd as VariableDecl:
            variables.append(vd)
            if let _ = vd.initializer {
                topLevelCodes.append(vd)
            }
        default:
            topLevelCodes.append(st)
        }
    }
    
    // TODO: improve to efficient
    public func replaceTopLevelCode(old: ASTNode, new: ASTNode) {
        guard old !== new else { return }
        
        if let index = (topLevelCodes.firstIndex { $0 === old }) {
            topLevelCodes[index] = new
        }
        
        if let index = (statements.firstIndex { $0 === old }) {
            statements[index] = new
        }
    }
    
    public func resolve(name: String) -> ASTNode? {
        // TOOD: consider statement order
        
        if let fn = (functions.first { $0.name == name }) {
            return fn
        }
        
        return nil
    }
}
