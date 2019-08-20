import SwiftcBasic
import SwiftcType
import SwiftcAST

public final class TypeChecker {
    private let source: SourceFile
    
    public init(source: SourceFile) {
        self.source = source
    }
    
    public func typeCheck() throws {
        for index in 0..<source.statements.count {
            source.statements[index] = try typeCheckStatement(source.statements[index],
                                                              context: source)
        }
    }
    
    public func typeCheckStatement(_ stmt: ASTNode,
                                   context: ASTContextNode) throws -> ASTNode {
        switch stmt {
        case let vd as VariableDecl:
            if let ie = vd.initializer {
                vd.initializer = try typeCheckExpr(ie,
                                                   context: context)
            }
        case let ex as ASTExprNode:
            return try typeCheckExpr(ex,
                                     context: context)
        default:
            break
        }
        return stmt
    }
    
    public func typeCheckExpr(_ expr: ASTExprNode,
                              context: ASTContextNode) throws -> ASTExprNode {
        let expr = try preCheckExpr(expr,
                                    context: context)
        
        let cs = ConstraintSystem()
        let exprType = try cs.generateConstraints(expr: expr)
        _ = exprType
        // TODO: apply
        return expr
    }
    
    public func preCheckExpr(_ expr: ASTExprNode,
                             context: ASTContextNode) throws -> ASTExprNode {
        let expr = try resolveDeclRef(expr: expr,
                                      context: context)
        return expr
    }
    
    public func resolveDeclRef(expr: ASTExprNode,
                               context: ASTContextNode) throws -> ASTExprNode {
        var error: Error?
        
        func tr(node: ASTExprNode, context: ASTContextNode?) -> ASTExprNode? {
            if let _ = error { return nil }
            
            switch node {
            case let node as UnresolvedDeclRefExpr:
                guard let context = context else {
                    error = MessageError("no context in resolving")
                    return nil
                }
                
                let name = node.name
                
                guard let target = context.resolve(name: name) else {
                    error = MessageError("failed to resolve: \(name)")
                    return nil
                }

                return DeclRefExpr(name: name, target: target)
            default:
                return nil
            }
        }
        
        let expr = expr.transformExpr(context: context, tr)
        
        if let error = error {
            throw error
        }
        
        return expr
    }
}
