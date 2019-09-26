import SwiftcBasic
import SwiftcType
import SwiftcAST

public final class ConstraintSolutionApplicator : ASTVisitor {
    public typealias VisitResult = ASTNode
    
    private let solution: ConstraintSystem.Solution
    
    public init(solution: ConstraintSystem.Solution)
    {
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
        if let calleeTy = node.callee.type as? FunctionType {
            let paramTy = calleeTy.parameter
            node.argument = try solution.coerce(expr: node.argument, to: paramTy)
            return try applyFixedType(expr: node)
        }
        
        throw MessageError("unconsidered")
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> ASTNode {
        _ = try applyFixedType(expr: node)
        
        guard let closureTy = node.type as? FunctionType else {
            throw MessageError("invalid closure type")
        }
        
        let index = node.body.count - 1
        guard var body = node.body[index] as? Expr else {
            throw MessageError("invalid body statement")
        }
        body = try solution.coerce(expr: body, to: closureTy.result)
        node.body[index] = body
        
        return node
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
    
    public func visitInjectIntoOptionalExpr(_ node: InjectIntoOptionalExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
    
    public func visitBindOptionalExpr(_ node: BindOptionalExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
    
    public func visitOptionalEvaluationExpr(_ node: OptionalEvaluationExpr) throws -> ASTNode {
        return try applyFixedType(expr: node)
    }
}

extension ConstraintSystem.Solution {
    public func apply(to expr: Expr,
                      context: DeclContext,
                      constraintSystem: ConstraintSystem) throws -> Expr
    {
        let applier = ConstraintSolutionApplicator(solution: self)
        switch try expr.walk(context: context,
                             preWalk: applier.preWalk,
                             postWalk: applier.postWalk)
        {
        case .continue(let node): return node as! Expr
        case .terminate: preconditionFailure()
        }
    }
    
    public func coerce(expr: Expr, to toTy: Type) throws -> Expr {
        let fromTy = try expr.typeOrThrow()
        if fromTy == toTy {
            return expr
        }
        
        let convRelOrNone = typeConversionRelations.first { (rel) in
            rel.left == fromTy && rel.right == toTy
        }
        
        if let convRel = convRelOrNone {
            switch convRel.conversion {
            case .deepEquality:
                return expr
            case .valueToOptional:
                guard let toOptTy = toTy as? OptionalType else {
                    throw MessageError("invalid relation")
                }
                var expr = try coerce(expr: expr, to: toOptTy.wrapped)
                expr = InjectIntoOptionalExpr(subExpr: expr, type: toTy)
                return expr
            case .optionalToOptional:
                return try coerceOptionalToOptional(expr: expr, to: toTy)
            }
        }
        
        // I think the following code is unnecessary
     
        switch toTy {
        case let toTy as OptionalType:
            if let _ = fromTy as? OptionalType {
                return try coerceOptionalToOptional(expr: expr, to: toTy)
            }
            
            var expr = try coerce(expr: expr, to: toTy.wrapped)
            expr = InjectIntoOptionalExpr(subExpr: expr, type: toTy)
            return expr
        default:
            break
        }
        
        throw MessageError("unconsidered")
    }
    
    private func coerceOptionalToOptional(expr: Expr, to toType: Type) throws -> Expr {
        let fromType = try expr.typeOrThrow()
        guard let fromTy = fromType as? OptionalType else { throw MessageError("not optional") }
        guard let toTy = toType as? OptionalType else { throw MessageError("not optional") }
        
        do {
            let fromOpts = fromTy.lookThroughAllOptionals()
            let fromDepth = fromOpts.count
            let toOpts = toTy.lookThroughAllOptionals()
            let toDepth = toOpts.count
            let depthDiff = toDepth - fromDepth
            if depthDiff > 0,
                toOpts[depthDiff] == fromTy
            {
                var expr = expr
                for i in 0..<depthDiff {
                    let optTy = toOpts[depthDiff - i - 1]
                    expr = InjectIntoOptionalExpr(subExpr: expr, type: optTy)
                }
                return expr
            }
        }
        
        let bindExpr = BindOptionalExpr(subExpr: expr, type: fromTy.wrapped)
        
        var expr = try coerce(expr: bindExpr, to: toTy.wrapped)
        expr = InjectIntoOptionalExpr(subExpr: expr, type: toTy)
        expr = OptionalEvaluationExpr(subExpr: expr, type: toTy)
        return expr
    }
}
