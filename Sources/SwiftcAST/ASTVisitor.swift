import SwiftcBasic

public protocol ASTVisitor : VisitorProtocol where VisitTarget == ASTNode {
    associatedtype VisitResult
    
    func visit(_ node: SourceFile) throws -> VisitResult
    func visit(_ node: FunctionDecl) throws -> VisitResult
    func visit(_ node: VariableDecl) throws -> VisitResult
    func visit(_ node: CallExpr) throws -> VisitResult
    func visit(_ node: ClosureExpr) throws -> VisitResult
    func visit(_ node: UnresolvedDeclRefExpr) throws -> VisitResult
    func visit(_ node: DeclRefExpr) throws -> VisitResult
    func visit(_ node: OverloadedDeclRefExpr) throws -> VisitResult
    func visit(_ node: IntegerLiteralExpr) throws -> VisitResult
    func visit(_ node: InjectIntoOptionalExpr) throws -> VisitResult
    func visit(_ node: BindOptionalExpr) throws -> VisitResult
    func visit(_ node: OptionalEvaluationExpr) throws -> VisitResult
}

extension ASTVisitor {
    public func startVisiting(_ node: ASTNode) throws -> VisitResult {
        try node.accept(visitor: self)
    }
}
