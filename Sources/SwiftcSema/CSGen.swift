import SwiftcBasic
import SwiftcType
import SwiftcAST

public final class ConstraintGenerator : ASTVisitor {
    public typealias VisitResult = Type
    
    private let cs: ConstraintSystem
    
    public init(constraintSystem: ConstraintSystem) {
        self.cs = constraintSystem
    }
    
    public func preWalk(node: ASTNode, context: DeclContext) throws -> PreWalkResult<ASTNode> {
        .continue(node)
    }
    
    public func postWalk(node: ASTNode, context: DeclContext) throws -> WalkResult<ASTNode> {
        let ty = try visit(node)
        cs.setASTType(for: node, ty)
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
        
        return cs.createTypeVariable()
    }
    
    public func visitCallExpr(_ node: CallExpr) throws -> Type {
        let callee = cs.astType(for: node.callee)!
        let arg = cs.astType(for: node.argument)!
        
        let tv = cs.createTypeVariable()
        
        cs.addConstraint(kind: .applicableFunction,
            left: FunctionType(parameter: arg, result: tv),
            right: callee)
        
        return tv
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> Type {
        let paramTy = cs.astType(for: node.parameter)!
        let resultTy = cs.createTypeVariable()
        let closureTy = FunctionType(parameter: paramTy, result: resultTy)
        
        let bodyTy = cs.astType(for: node.body[0])!
        
        cs.addConstraint(kind: .bind, left: bodyTy, right: resultTy)
        
        return closureTy
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> Type {
        throw MessageError("unresolved")
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) throws -> Type {
        let tv = cs.createTypeVariable()
        
        let choice = OverloadChoice(decl: node.target)

        cs.resolveOverload(boundType: tv, choice: choice, location: node)

        return tv
    }
    
    public func visitOverloadedDeclRefExpr(_ node: OverloadedDeclRefExpr) throws -> Type {
        let tv = cs.createTypeVariable()
        
        return tv
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> Type {
        return PrimitiveType.int
    }
    
}

extension ConstraintSystem {
    public func generateConstraints(expr: ASTExprNode,
                                    context: DeclContext) throws {
        let gen = ConstraintGenerator(constraintSystem: self)
        
        try expr.walk(context: context,
                      preWalk: gen.preWalk,
                      postWalk: gen.postWalk)
    }
}
