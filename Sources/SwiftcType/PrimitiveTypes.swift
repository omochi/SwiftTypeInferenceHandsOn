public protocol _PrimitiveType : _EquatableType, _LeafType {
}

public struct VoidType : _PrimitiveType {
    public init() {}
    
    public var description: String { "Void" }
}

public struct IntType : _PrimitiveType {
    public init() {}
    
    public var description: String { "Int" }
}

public struct StringType : _PrimitiveType {
    public init() {}
    
    public var description: String { "String" }
}
