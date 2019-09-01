import SwiftcType

public final class UnresolvedDeclRefExpr : Expr {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public var name: String
    public var type: Type?
    
    public init(source: SourceFile,
                sourceRange: SourceRange,
                name: String)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.name = name
    }
    
    public var descriptionPartsTail: [String] { Exprs.descriptionParts(self) }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitUnresolvedDeclRefExpr(self)
    }
}
