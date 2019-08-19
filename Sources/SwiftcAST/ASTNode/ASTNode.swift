public protocol ASTNode : AnyObject {
    func accept<V: ASTVisitor>(visitor: V) -> V.VisitResult
}
