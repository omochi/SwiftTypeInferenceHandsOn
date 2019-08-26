public protocol ASTNode : AnyObject, CustomStringConvertible {
    // break retain cycle
    func dispose()
    
    var source: SourceFile { get }
    var sourceRange: SourceRange { get }
    
    func accept<V: ASTVisitor>(visitor: V) throws -> V.VisitResult
}

extension ASTNode {
    public func dispose() {}
}

extension ASTNode {
    public var sourceLocationRange: SourceLocationRange {
        sourceRange.toLocation(name: source.fileName, map: source.sourceLineMap)
    }
}
