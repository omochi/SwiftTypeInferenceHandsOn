public protocol ASTNode : AnyObject {
    // break retain cycle
    func dispose()
    
    var sourceRange: SourceRange { get }
    
    func accept<V: ASTVisitor>(visitor: V) throws -> V.VisitResult
}

extension ASTNode {
    public func dispose() {}
}

extension ASTNode {
    public func sourceLocationRange(source: SourceFile) -> SourceLocationRange {
        sourceRange.toLocation(name: source.fileName, map: source.sourceLineMap)
    }
}
