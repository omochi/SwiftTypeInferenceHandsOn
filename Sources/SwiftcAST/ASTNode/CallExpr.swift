import SwiftcBasic
import SwiftcType

public final class CallExpr : Expr {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public var callee: Expr
    public var argument: Expr
    public var type: Type?
    public init(source: SourceFile,
                sourceRange: SourceRange,
                callee: Expr,
                argument: Expr)
    {
        self.source = source
        self.sourceRange = sourceRange
        self.callee = callee
        self.argument = argument
    }
    
    public var descriptionPartsTail: [String] { Exprs.descriptionParts(self) }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visit(self)
    }
}
