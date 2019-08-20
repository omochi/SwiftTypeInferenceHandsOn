import SwiftcType

public protocol ASTExprNode : ASTNode {
    var type: Type? { get set }
}
