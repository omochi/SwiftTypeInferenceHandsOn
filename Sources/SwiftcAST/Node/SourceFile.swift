import Foundation

public final class SourceFile : ASTNode {
    public var statements: [ASTNode]
    
    public init(statements: [ASTNode]) {
        self.statements = statements
    }
}
