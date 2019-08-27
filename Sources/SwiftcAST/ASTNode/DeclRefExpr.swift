import SwiftcType

public final class DeclRefExpr : Expr {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public var name: String
    public var target: ValueDecl!
    public var type: Type?
    
    public init(source: SourceFile,
                sourceRange: SourceRange,
                name: String,
                target: ValueDecl)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.name = name
        self.target = target
        source.ownedNodes.append(self)
    }
    
    public func dispose() {
        target = nil
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitDeclRefExpr(self)
    }
}
