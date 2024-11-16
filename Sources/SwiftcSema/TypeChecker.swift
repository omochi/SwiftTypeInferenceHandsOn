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
    
    // ref: typeCheckStmt in TypeCheckStmt.cpp
    public func typeCheckStatement(_ stmt: ASTNode,
                                   context: DeclContext) throws -> ASTNode {
        switch stmt {
        case let vd as VariableDecl:
           return try typeCheckVariableDecl(vd, context: context)
        case let ex as Expr:
            return try typeCheckExpr(ex,
                                     context: context,
                                     callbacks: nil)
        default:
            break
        }
        return stmt
    }
    
    // ref: typeCheckBinding at TypeCheckConstraints.cpp
    public func typeCheckVariableDecl(_ vd: VariableDecl,
                                      context: DeclContext) throws -> ASTNode {
        if var ie = vd.initializer {
            var varTy: Type!
            
            let callbacks = ExprTypeCheckCallbacks(
                didGenerateConstraints: { (cts, expr, context) in
                    let exprTy = cts.astType(for: expr)!
                    
                    if let ta = vd.typeAnnotation {
                        varTy = ta
                    } else {
                        varTy = exprTy
                    }
                    
                    // <Q05 hint="call addConstraint"/>
            },
                didFoundSolution: nil,
                didApplySolution: { (cts, solution, expr, context) -> Expr in
                    let varTy = cts.simplify(type: varTy)
                    vd.type = varTy

                    // <Q13 hint="see visitCallExpr" />
                    return expr
            })
                
            ie = try typeCheckExpr(ie,
                                   context: vd,
                                   callbacks: callbacks)
            
            vd.initializer = ie
        }
        
        return vd
    }
    
    // ref: typeCheckExpression at TypeCheckConstraints.cpp
    public func typeCheckExpr(_ expr: Expr,
                              context: DeclContext,
                              callbacks: ExprTypeCheckCallbacks?) throws -> Expr {
        var expr = try preCheckExpr(expr,
                                    context: context)
        
        let cts = ConstraintSystem()
        try cts.generateConstraints(expr: expr,
                                    context: context)
        try callbacks?.didGenerateConstraints?(cts, expr, context)
        
        let solutions = cts.solve()
        guard let solution = solutions.first else {
            throw MessageError("no solution")
        }
        
        expr = try callbacks?.didFoundSolution?(cts, solution, expr, context) ?? expr
        
        expr = try solution.apply(to: expr, context: context,
                                  constraintSystem: cts)
        
        expr = try callbacks?.didApplySolution?(cts, solution, expr, context) ?? expr
        
        return expr
    }
    
    // ref: preCheckExpression at TypeCheckConstraints.cpp
    private func preCheckExpr(_ expr: Expr,
                              context: DeclContext) throws -> Expr {
        let expr = try resolveDeclRef(expr: expr,
                                      context: context)
        return expr
    }
    
    private func resolveDeclRef(expr: Expr,
                                context: DeclContext) throws -> Expr {
        func tr(node: ASTNode, context: DeclContext) throws -> ASTNode? {
            switch node {
            case let node as UnresolvedDeclRefExpr:
                let name = node.name
                
                let targets = context.resolve(name: name)
                guard targets.count > 0 else {
                    throw MessageError("failed to resolve: \(name)")
                }
                
                if targets.count == 1 {
                    return DeclRefExpr(source: source, sourceRange: node.sourceRange,
                                       name: name, target: targets[0])
                } else {
                    return OverloadedDeclRefExpr(source: source, sourceRange: node.sourceRange,
                                                 name: name, targets: targets)
                }
            default:
                return nil
            }
        }
        
        return try expr.transform(context: context, tr) as! Expr
    }
}
