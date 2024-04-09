import SwiftcBasic
import SwiftcType

public final class SourceFile : Decl {
    public var source: SourceFile { self }
    public let sourceRange: SourceRange
    public var parentContext: DeclContext? { nil }
    
    public var fileName: String?
    public var sourceLineMap: SourceLineMap
    
    public var statements: [ASTNode] = []
    public var ownedNodes: [ASTNode] = []
    
    public init(sourceRange: SourceRange,
                fileName: String?,
                sourceLineMap: SourceLineMap)
    {
        self.sourceRange = sourceRange
        self.fileName = fileName
        self.sourceLineMap = sourceLineMap
    }
    
    public func dispose() {
        for node in ownedNodes {
            node.dispose()
        }
        ownedNodes.removeAll()
    }
    
    public var descriptionPartsTail: [String] {
        var parts: [String] = []
        if let name = fileName {
            parts.append(name)
        }
        return parts
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visit(self)
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
