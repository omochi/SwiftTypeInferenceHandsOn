import SwiftcBasic
import SwiftcType
import SwiftcAST

public final class ConstraintGenerator : ASTVisitor {
    public typealias VisitResult = Type
    
    private let cs: ConstraintSystem
    
    public init(constraintSystem: ConstraintSystem) {
        self.cs = constraintSystem
    }
    
    public func preWalk(node: ASTNode, context: ASTContextNode) throws -> PreWalkResult<ASTNode> {
        .continue(node)
    }
    
    public func postWalk(node: ASTNode, context: ASTContextNode) throws -> WalkResult<ASTNode> {
        _ = try visit(node)
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
        
        let tv = cs.createTypeVariable(for: node)
        return tv
    }
    
    public func visitCallExpr(_ node: CallExpr) throws -> Type {
        let callee = cs.astType(for: node.callee)!
        let arg = cs.astType(for: node.argument)!
        
        let tv = cs.createTypeVariable(for: node)
        
        cs.addConstraint(.applicableFunction(
            left: FunctionType(parameter: arg, result: tv),
            right: callee))
        
        return tv
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> Type {
        let paramTy = cs.astType(for: node.parameter)!
        let resultTy = cs.createTypeVariable()
        let closureTy = FunctionType(parameter: paramTy, result: resultTy)
        cs.setASTType(for: node, closureTy)
        
        let bodyTy = cs.astType(for: node.body[0])!
        
        cs.addConstraint(.bind(left: bodyTy, right: resultTy))
        
        return closureTy
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> Type {
        throw MessageError("unresolved")
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) throws -> Type {
        let tv = cs.createTypeVariable(for: node)
        
        let choice = OverloadChoice(decl: node.target)

        try cs.resolveOverload(node: node, boundType: tv, choice: choice)
        
        return tv
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> Type {
        let ty = PrimitiveType.int
        cs.setASTType(for: node, ty)
        return ty
    }
    
}

extension ConstraintSystem {
    public func generateConstraints(expr: ASTExprNode,
                                    context: ASTContextNode) throws {
        let gen = ConstraintGenerator(constraintSystem: self)
        
        try expr.walk(context: context,
                      preWalk: gen.preWalk,
                      postWalk: gen.postWalk)
    }
}
