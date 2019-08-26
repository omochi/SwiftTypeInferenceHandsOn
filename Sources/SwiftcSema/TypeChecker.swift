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
                                   context: DeclContext) throws -> ASTNode {
        switch stmt {
        case let vd as VariableDecl:
            if let ie = vd.initializer {
                vd.initializer = try typeCheckExpr(ie,
                                                   context: vd)
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
                              context: DeclContext) throws -> ASTExprNode {
        var expr = try preCheckExpr(expr,
                                    context: context)
        
        let cs = ConstraintSystem()
        try cs.generateConstraints(expr: expr,
                                   context: context)
        let solution = try cs.solve()
        expr = try (solution.apply(to: expr, context: context) as! ASTExprNode)
        return expr
    }
    
    public func preCheckExpr(_ expr: ASTExprNode,
                             context: DeclContext) throws -> ASTExprNode {
        let expr = try resolveDeclRef(expr: expr,
                                      context: context)
        return expr
    }
    
    public func resolveDeclRef(expr: ASTExprNode,
                               context: DeclContext) throws -> ASTExprNode {
        func tr(node: ASTNode, context: DeclContext) throws -> ASTNode? {
            switch node {
            case let node as UnresolvedDeclRefExpr:
                let name = node.name
                
                let targets = context.resolve(name: name)
                guard targets.count > 0 else {
                    throw MessageError("failed to resolve: \(name)")
                }
                
                if targets.count == 1 {
                    return DeclRefExpr(name: name, target: targets[0], source: source)
                } else {
                    return OverloadedDeclRefExpr(name: name, targets: targets, source: source)
                }
            default:
                return nil
            }
        }
        
        return try expr.transform(context: context, tr) as! ASTExprNode
    }
}
