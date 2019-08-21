import SwiftcBasic
import SwiftcAST

extension ConstraintSystem.Solution {
    public func apply(to expr: ASTExprNode,
                      context: ASTContextNode) throws -> ASTExprNode {
        func tr(node: ASTExprNode, context: ASTContextNode?) throws -> ASTExprNode? {
            if let _ = node.type {
                return nil
            }
            guard let ty = fixedType(for: node) else {
                throw MessageError("node type unknown: \(node)")
            }
            node.type = ty
            return node
        }
        
        return try expr.transformExpr(context: context, tr)
    }
}
