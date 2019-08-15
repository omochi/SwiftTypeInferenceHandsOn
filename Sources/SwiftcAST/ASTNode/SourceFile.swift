public final class SourceFile : ASTContextNode
{
    public var parentContext: ASTContextNode? { nil }
    public var statements: [ASTNode] = []
    public var functions: [FunctionDecl] = []
    public var topLevelCodes: [ASTNode] = []
    
    public init() {
    }
    
    public func addStatement(_ st: ASTNode) {
        statements.append(st)
        
        switch st {
        case let fn as FunctionDecl:
            functions.append(fn)
        case let vd as VariableDecl:
            if let _ = vd.initializer {
                topLevelCodes.append(vd)
            }
        default:
            break
        }
    }
    
    public func replaceTopLevelCode(old: ASTNode, new: ASTNode) {
        guard old !== new else { return }
        
        if let index = (topLevelCodes.firstIndex { $0 === old }) {
            topLevelCodes[index] = new
        }
        
        if let index = (statements.firstIndex { $0 === old }) {
            statements[index] = new
        }
    }
}
