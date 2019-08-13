import SwiftSyntax

public final class SourceFile : ASTNode,
    ASTScope
{
    public let scopeRange: Range<AbsolutePosition>
    
    public var statements: [ASTNode]
    
    public init(statements: [ASTNode],
                sourceRange: Range<AbsolutePosition>)
    {
        self.statements = statements
        self.scopeRange = sourceRange
    }
    
    public var source: SourceFile { self }
    
    public var sourceRange: Range<AbsolutePosition>? { scopeRange }
    
}
