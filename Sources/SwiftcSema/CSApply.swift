import SwiftcBasic
import SwiftcAST

public final class ConstraintSolutionApplicator : ASTVisitor {
    public typealias VisitResult = ASTNode
    
    private let cts: ConstraintSystem
    private let solution: ConstraintSystem.Solution
    
    public init(constraintSystem: ConstraintSystem,
                solution: ConstraintSystem.Solution)
    {
        self.cts = constraintSystem
        self.solution = solution
    }
    
    public func preWalk(node: ASTNode, context: DeclContext) throws -> PreWalkResult<ASTNode> {
        .continue(node)
    }
    
    public func postWalk(node: ASTNode, context: DeclContext) throws -> WalkResult<ASTNode> {
        let node = try visit(node)
        return .continue(node)
    }
    
    private func applyFixedType(expr: Expr) throws -> Expr {
        let ty = try solution.fixedTypeOrThrow(for: expr)
        expr.type = ty
        return expr
    }
    
    public func visitSourceFile(_ node: SourceFile) throws -> ASTNode {
        node
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) throws -> ASTNode {
        node
    }
    
    public func visitVariableDecl(_ node: VariableDecl) throws -> ASTNode {
        let ty = try solution.fixedTypeOrThrow(for: node)
        node.type = ty
        return node
    }
    
    public func visitCallExpr(_ node: CallExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> ASTNode {
        throw MessageError("invalid node: \(node)")
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
    
    public func visitOverloadedDeclRefExpr(_ node: OverloadedDeclRefExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
    
}

extension ConstraintSystem.Solution {
    public func apply(to expr: ASTNode,
                      context: DeclContext,
                      constraintSystem: ConstraintSystem) throws -> ASTNode
    {
        let applier = ConstraintSolutionApplicator(constraintSystem: constraintSystem,
                                                   solution: self)
        switch try expr.walk(context: context,
                             preWalk: applier.preWalk,
                             postWalk: applier.postWalk)
        {
        case .continue(let node): return node
        case .terminate: preconditionFailure()
        }
    }
}
