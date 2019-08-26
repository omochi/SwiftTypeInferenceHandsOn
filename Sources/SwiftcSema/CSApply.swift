import SwiftcBasic
import SwiftcAST

extension ConstraintSystem.Solution {
    public func apply(to expr: ASTNode,
                      context: DeclContext) throws -> ASTNode {
        func tr(node: ASTNode, context: DeclContext) throws -> ASTNode? {
            guard let ty = fixedType(for: node) else {
                throw MessageError("node type unknown: \(node)")
            }
            
            if let expr = node as? ASTExprNode {
                expr.type = ty
                return nil
            }
            
            if let vd = node as? VariableDecl {
                vd.type = ty
                return nil
            }
        
            return nil
        }
        
        return try expr.transform(context: context, tr)
    }
}
