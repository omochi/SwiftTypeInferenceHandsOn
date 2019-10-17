import SwiftcAST

// ref: ExprTypeCheckListener at TypeChecker.h
public struct ExprTypeCheckCallbacks {
    public var didGenerateConstraints: ((ConstraintSystem, Expr, DeclContext) throws -> Void)?
    public var didFoundSolution: ((ConstraintSystem, ConstraintSystem.Solution, Expr, DeclContext) throws -> Expr)?
    public var didApplySolution: ((ConstraintSystem, ConstraintSystem.Solution, Expr, DeclContext) throws -> Expr)?
}
