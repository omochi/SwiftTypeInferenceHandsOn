public protocol _PrimitiveType : _EquatableType, _LeafType {
}

public struct IntType : _PrimitiveType {
    public init() {}
    
    public var description: String {
        return "Int"
    }
}

public struct StringType : _PrimitiveType {
    public init() {}
    
    public var description: String {
        return "String"
    }
}
