import SwiftcType

public final class ClosureExpr : Expr, DeclContext {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public weak var parentContext: DeclContext?
    public var parameter: VariableDecl
    public var returnType: Type?
    public var body: [ASTNode] = []
    public var type: Type?
    
    public init(source: SourceFile,
                sourceRange: SourceRange,
                parentContext: DeclContext?,
                parameter: VariableDecl,
                returnType: Type?)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.parentContext = parentContext
        self.parameter = parameter
        self.returnType = returnType
    }
    
    public var descriptionPartsTail: [String] {
        var parts: [String] = []        
        if let returnType = self.returnType {
            parts.append("returnType=\"\(str(returnType))\"")
        }
        parts += Exprs.descriptionParts(self)
        return parts
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitClosureExpr(self)
    }
    
    public var interfaceType: Type? { type }
    
    public func resolveInSelf(name: String) -> [ValueDecl] {
        var decls: [ValueDecl] = []
        if parameter.name == name {
            decls.append(parameter)
        }
        return decls
    }
}
