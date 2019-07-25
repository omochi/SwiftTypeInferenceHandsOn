public protocol PrimitiveType : EquatableType {
    
}

extension PrimitiveType {
    public func map(_ f: (Type) throws -> Type) rethrows -> Type {
        try f(self)
    }
}

public struct IntType : PrimitiveType {
    public init() {}
    
    public var description: String {
        return "Int"
    }
}

public struct StringType : PrimitiveType {
    public init() {}
    
    public var description: String {
        return "String"
    }
}
