import SwiftSyntax
public final class UnresolvedDeclRefExpr : ASTNodeBase {
    public var name: String
    
    public init(name: String,
                sourceRange: Range<AbsolutePosition>?)
    {
        self.name = name
        super.init(sourceRange: sourceRange)
    }
}
