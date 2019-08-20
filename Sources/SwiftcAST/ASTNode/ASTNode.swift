public protocol ASTNode : AnyObject {
    func accept<V: ASTVisitor>(visitor: V) -> V.VisitResult
    
    func accept<V: ASTFailableVisitor>(visitor: V) throws -> V.VisitResult
}
