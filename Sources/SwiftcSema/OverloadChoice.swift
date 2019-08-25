import SwiftcAST

public struct OverloadChoice {
    public var decl: ASTNode
    
    public init(decl: ASTNode) {
        self.decl = decl
    }
}
