import SwiftcBasic
import SwiftcType
import SwiftcAST

public final class ConstraintGenerator : ASTVisitor {
    public typealias VisitResult = Type
    
    private let cts: ConstraintSystem
    
    public init(constraintSystem: ConstraintSystem) {
        self.cts = constraintSystem
    }
    
    public func preWalk(node: ASTNode, context: DeclContext) throws -> PreWalkResult<ASTNode> {
        .continue(node)
    }
    
    public func postWalk(node: ASTNode, context: DeclContext) throws -> WalkResult<ASTNode> {
        let ty = try visit(node)
        cts.setASTType(for: node, ty)
        return .continue(node)
    }
    
    public func visitSourceFile(_ node: SourceFile) throws -> Type {
        throw MessageError("source")
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) throws -> Type {
        throw MessageError("function")
    }
    
    public func visitVariableDecl(_ node: VariableDecl) throws -> Type {
        if let ta = node.typeAnnotation {
            return ta
        }
        
        return cts.createTypeVariable()
    }
    
    public func visitCallExpr(_ node: CallExpr) throws -> Type {
        let callee = try cts.astTypeOrThrow(for: node.callee)
        let arg = try cts.astTypeOrThrow(for: node.argument)
        
        let tv = cts.createTypeVariable()
        
        // <Q07 hint="call addConstraint" />
        
        return tv
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> Type {
        let paramTy = try cts.astTypeOrThrow(for: node.parameter)
        
        func resultTy_() -> Type {
            if let ret = node.returnType {
                return ret
            }
            return cts.createTypeVariable()
        }
        
        let resultTy = resultTy_()

        let closureTy = FunctionType(parameter: paramTy, result: resultTy)
        
        let bodyTy = try cts.astTypeOrThrow(for: node.body.last!)
        
        // <Q06 hint="call addConstraint" />
        
        return closureTy
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> Type {
        throw MessageError("unresolved")
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) throws -> Type {
        let tv = cts.createTypeVariable()
        
        let choice = OverloadChoice(decl: node.target)

        cts.resolveOverload(boundType: tv, choice: choice, location: node)

        return tv
    }
    
    public func visitOverloadedDeclRefExpr(_ node: OverloadedDeclRefExpr) throws -> Type {
        let tv = cts.createTypeVariable()
        
        var cs: [Constraint] = []
        for target in node.targets {
            let choice = OverloadChoice(decl: target)
            cs.append(.bindOverload(left: tv, choice: choice, location: node))
        }
        cts.addDisjunctionConstraint(cs)
        return tv
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> Type {
        return PrimitiveType.int
    }
    
    public func visitInjectIntoOptionalExpr(_ node: InjectIntoOptionalExpr) throws -> Type {
        throw MessageError("invalid")
    }
    
    public func visitBindOptionalExpr(_ node: BindOptionalExpr) throws -> Type {
        // OptionalObject constraint
        unimplemented()
    }
    
    public func visitOptionalEvaluationExpr(_ node: OptionalEvaluationExpr) throws -> Type {
        // subExpr conv .some(subExpr)
        unimplemented()
    }
    
}

extension ConstraintSystem {
    public func generateConstraints(expr: Expr,
                                    context: DeclContext) throws {
        let gen = ConstraintGenerator(constraintSystem: self)
        
        try expr.walk(context: context,
                      preWalk: gen.preWalk,
                      postWalk: gen.postWalk)
    }
}
