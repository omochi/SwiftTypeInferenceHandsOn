import SwiftcBasic

public protocol ASTVisitor : VisitorProtocol where VisitTarget == ASTNode {
    associatedtype VisitResult
    
    func visitSourceFile(_ node: SourceFile) -> VisitResult
    func visitFunctionDecl(_ node: FunctionDecl) -> VisitResult
    func visitVariableDecl(_ node: VariableDecl) -> VisitResult
    func visitCallExpr(_ node: CallExpr) -> VisitResult
    func visitClosureExpr(_ node: ClosureExpr) -> VisitResult
    func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) -> VisitResult
    func visitDeclRefExpr(_ node: DeclRefExpr) -> VisitResult
    func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) -> VisitResult
}

extension ASTVisitor {
    public func visit(_ node: ASTNode) -> VisitResult {
        node.accept(visitor: self)
    }
}

public protocol ASTFailableVisitor : FailableVisitorProtocol where VisitTarget == ASTNode {
    associatedtype VisitResult
    
    func visitSourceFile(_ node: SourceFile) throws -> VisitResult
    func visitFunctionDecl(_ node: FunctionDecl) throws -> VisitResult
    func visitVariableDecl(_ node: VariableDecl) throws -> VisitResult
    func visitCallExpr(_ node: CallExpr) throws -> VisitResult
    func visitClosureExpr(_ node: ClosureExpr) throws -> VisitResult
    func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> VisitResult
    func visitDeclRefExpr(_ node: DeclRefExpr) throws -> VisitResult
    func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> VisitResult
}

extension ASTFailableVisitor {
    public func visit(_ node: ASTNode) throws -> VisitResult {
        try node.accept(visitor: self)
    }
}
