public protocol ASTNode : AnyObject {
    // break retain cycle
    func dispose()
    
    func accept<V: ASTVisitor>(visitor: V) throws -> V.VisitResult
}

extension ASTNode {
    public func dispose() {}
}
