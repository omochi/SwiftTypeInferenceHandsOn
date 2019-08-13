import SwiftSyntax

public class ASTScopeBase : ASTScope {
    public unowned let source: SourceFile
    public let scopeRange: Range<AbsolutePosition>
    
    public init(source: SourceFile,
                scopeRange: Range<AbsolutePosition>)
    {
        self.source = source
        self.scopeRange = scopeRange
    }
}
