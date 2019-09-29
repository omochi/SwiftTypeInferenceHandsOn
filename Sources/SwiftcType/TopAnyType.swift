// This is a `Swift.Any`
// actually protocol composition...
public struct TopAnyType : Hashable, _EquatableType {
    public init() {}
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : TypeVisitor {
        try visitor.visit(self)
    }
    
    public func print(options: TypePrintOptions) -> String {
        "Any"
    }
}
