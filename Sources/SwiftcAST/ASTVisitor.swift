import SwiftcBasic

public protocol ASTVisitor : VisitorProtocol where VisitTarget == ASTNode {
    associatedtype VisitResult
    
    func visitSourceFile(_ node: SourceFile) throws -> VisitResult
    func visitFunctionDecl(_ node: FunctionDecl) throws -> VisitResult
    func visitVariableDecl(_ node: VariableDecl) throws -> VisitResult
    func visitCallExpr(_ node: CallExpr) throws -> VisitResult
    func visitClosureExpr(_ node: ClosureExpr) throws -> VisitResult
    func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> VisitResult
    func visitDeclRefExpr(_ node: DeclRefExpr) throws -> VisitResult
    func visitOverloadedDeclRefExpr(_ node: OverloadedDeclRefExpr) throws -> VisitResult
    func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> VisitResult
    func visitInjectIntoOptionalExpr(_ node: InjectIntoOptionalExpr) throws -> VisitResult
}

extension ASTVisitor {
    public func visit(_ node: ASTNode) throws -> VisitResult {
        try node.accept(visitor: self)
    }
}
