public protocol ASTNode : AnyObject {
    func accept<V: ASTVisitor>(visitor: V) throws -> V.VisitResult
}
