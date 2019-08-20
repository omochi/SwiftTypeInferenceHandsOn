import SwiftcBasic
import SwiftcType
import SwiftcAST

public final class ConstraintGenerator : ASTFailableVisitor {
    public typealias VisitResult = Type
    
    public let system: ConstraintSystem
    
    public init(system: ConstraintSystem) {
        self.system = system
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
        let callee = try visit(node.callee)
        let arg = try visit(node.argument)
        
        let tv = system.createTypeVariable(for: node)
        
        system.addConstraint(.applicableFunction(
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
        guard let ty = system.astType(for: node.target) else {
            throw MessageError("untyped ref target")
        }
        system.setASTType(for: node, ty)
        return ty
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> Type {
        let ti = PrimitiveType.int
        system.setASTType(for: node, ti)
        return ti
    }
    
}

extension ConstraintSystem {
    public func generateConstraints(expr: ASTExprNode) throws -> Type {
        let gen = ConstraintGenerator(system: self)
        
        return try gen.visit(expr)
    }
}
