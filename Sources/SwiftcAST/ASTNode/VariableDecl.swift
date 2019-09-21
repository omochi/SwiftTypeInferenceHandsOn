import SwiftcType

public final class VariableDecl : ValueDecl {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public weak var parentContext: DeclContext?
    public var name: String
    public var initializer: Expr?
    public var typeAnnotation: Type?
    public var type: Type?
    public init(source: SourceFile,
                sourceRange: SourceRange,
                parentContext: DeclContext,
                name: String,
                initializer: Expr?,
                typeAnnotation: Type?)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.name = name
        self.initializer = initializer
        self.typeAnnotation = typeAnnotation
    }
    
    public var interfaceType: Type? { type }
    
    public var descriptionPartsTail: [String] {
        var parts: [String] = []
        
        let type = self.typeAnnotation ?? self.type
        parts.append("type=\"\(str(type))\"")
        
        parts += ValueDecls.descriptionParts(self)
        
        return parts
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitVariableDecl(self)
    }

    public func resolveInSelf(name: String) -> [ValueDecl] {
        var decls: [ValueDecl] = []
        if self.name == name {
            decls.append(self)
        }
        return decls
    }
}
