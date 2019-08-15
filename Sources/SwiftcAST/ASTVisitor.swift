import SwiftcBasic

public protocol ASTVisitor {
    associatedtype VisitResult
    
    func visit(node: ASTNode) -> VisitResult
    
    func visitSourceFile(_ node: SourceFile) -> VisitResult
    func visitFunctionDecl(_ node: FunctionDecl) -> VisitResult
    func visitVariableDecl(_ node: VariableDecl) -> VisitResult
    func visitCallExpr(_ node: CallExpr) -> VisitResult
    func visitClosureExpr(_ node: ClosureExpr) -> VisitResult
    func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) -> VisitResult
    func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) -> VisitResult
}

extension ASTVisitor {
    public func visit(node: ASTNode) -> VisitResult {
        switch node {
        case let n as SourceFile:
            return visitSourceFile(n)
        case let n as FunctionDecl:
            return visitFunctionDecl(n)
        case let n as VariableDecl:
            return visitVariableDecl(n)
        case let n as CallExpr:
            return visitCallExpr(n)
        case let n as ClosureExpr:
            return visitClosureExpr(n)
        case let n as UnresolvedDeclRefExpr:
            return visitUnresolvedDeclRefExpr(n)
        case let n as IntegerLiteralExpr:
            return visitIntegerLiteralExpr(n)
        default:
            unimplemented()
        }
    }
}
