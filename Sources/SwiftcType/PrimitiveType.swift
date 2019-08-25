public struct PrimitiveType : _EquatableType {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public var description: String { name }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Self.self))
        hasher.combine(name)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : TypeVisitor {
        try visitor.visitPrimitiveType(self)
    }
        
    public static var void: PrimitiveType { PrimitiveType(name: "Void") }
    public static var int: PrimitiveType { PrimitiveType(name: "Int") }
    public static var string: PrimitiveType { PrimitiveType(name: "String") }
}
