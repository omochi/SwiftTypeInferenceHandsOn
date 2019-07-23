public protocol PrimitiveType : Type {
    
}

extension PrimitiveType {
    public func map(_ f: (AnyType) throws -> AnyType) rethrows -> AnyType {
        try f(asAnyType())
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
