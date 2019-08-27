import SwiftcType

public final class ClosureExpr : Expr, DeclContext {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public weak var parentContext: DeclContext?
    public var parameter: VariableDecl
    public var body: [ASTNode] = []
    public var type: Type?
    
    public init(source: SourceFile,
                sourceRange: SourceRange,
                parentContext: DeclContext?,
                parameter: VariableDecl)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.parentContext = parentContext
        self.parameter = parameter
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
