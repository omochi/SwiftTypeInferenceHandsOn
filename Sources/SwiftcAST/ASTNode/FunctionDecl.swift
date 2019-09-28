import SwiftcType

public final class FunctionDecl : ValueDecl {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public weak var parentContext: DeclContext?
    public var name: String
    public var parameterType: Type
    public var resultType: Type
    public init(source: SourceFile,
                sourceRange: SourceRange,
                parentContext: DeclContext?,
                name: String,
                parameterType: Type,
                resultType: Type)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.parentContext = parentContext
        self.name = name
        self.parameterType = parameterType
        self.resultType = resultType
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visit(self)
    }
    
    public var descriptionPartsTail: [String] { ValueDecls.descriptionParts(self) }
    
    public var interfaceType: Type? {
        FunctionType(parameter: parameterType, result: resultType)
    }
    
    public func resolveInSelf(name: String) -> [ValueDecl] {
        var decls: [ValueDecl] = []
        if self.name == name {
            decls.append(self)
        }
        return decls
    }
}
