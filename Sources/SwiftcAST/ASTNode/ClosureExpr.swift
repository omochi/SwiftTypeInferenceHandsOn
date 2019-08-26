import SwiftcType

public final class ClosureExpr : ASTExprNode, DeclContext {
    public let sourceRange: SourceRange
    public weak var parentContext: DeclContext?
    public var parameter: VariableDecl
    public var body: [ASTNode] = []
    public var type: Type?
    
    public init(sourceRange: SourceRange,
                parentContext: DeclContext?,
                parameter: VariableDecl)
    {
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
