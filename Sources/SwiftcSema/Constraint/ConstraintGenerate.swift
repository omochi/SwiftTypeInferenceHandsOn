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
        let type = try visit(node)
        cs.setASTType(for: node, type)
        return .continue(node)
    }
    
    public func visitSourceFile(_ node: SourceFile) throws -> Type {
        throw MessageError("source")
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) throws -> Type {
        throw MessageError("function")
    }
    
    public func visitVariableDecl(_ node: VariableDecl) throws -> Type {
        throw MessageError("variable")
    }
    
    public func visitCallExpr(_ node: CallExpr) throws -> Type {
        let callee = cs.astType(for: node.callee)!
        let arg = cs.astType(for: node.argument)!
        
        let tv = cs.createTypeVariable()
        
        cs.addConstraint(.applicableFunction(
            left: FunctionType(parameter: arg, result: tv),
            right: callee))
        
        return tv
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> Type {
        // TODO
        unimplemented()
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> Type {
        throw MessageError("unresolved")
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) throws -> Type {
        guard let ty = cs.astType(for: node.target) else {
            throw MessageError("untyped ref target")
        }
        return ty
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> Type {
        PrimitiveType.int
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
