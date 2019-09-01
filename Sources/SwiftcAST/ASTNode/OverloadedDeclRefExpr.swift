import SwiftcType

public final class OverloadedDeclRefExpr : Expr {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public var name: String
    public var targets: [ValueDecl]
    public var type: Type?
    
    public init(source: SourceFile,
                sourceRange: SourceRange,
                name: String,
                targets: [ValueDecl])
    {
        self.source = source
        self.sourceRange = sourceRange
        self.name = name
        self.targets = targets
        source.ownedNodes.append(self)
    }
    
    public func dispose() {
        targets.removeAll()
    }
    
    public var descriptionPartsTail: [String] { Exprs.descriptionParts(self) }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitOverloadedDeclRefExpr(self)
    }
}
