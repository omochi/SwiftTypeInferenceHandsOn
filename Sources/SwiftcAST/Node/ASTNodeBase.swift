import SwiftSyntax

public class ASTNodeBase : ASTNode {
    public let sourceRange: Range<AbsolutePosition>?
    
    public init(sourceRange: Range<AbsolutePosition>?) {
        self.sourceRange = sourceRange
    }
}
