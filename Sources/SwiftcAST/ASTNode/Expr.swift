import SwiftcType

public protocol Expr : ASTNode {
    var type: Type? { get set }
}
