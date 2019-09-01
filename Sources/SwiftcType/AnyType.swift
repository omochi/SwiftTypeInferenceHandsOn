public struct AnyType : Hashable, CustomStringConvertible {
    public var value: Type
    
    public init(_ value: Type) {
        self.value = value
    }
    
    public var description: String {
        value.description
    }
    
    public static func ==(lhs: AnyType, rhs: AnyType) -> Bool {
        lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}

extension Type {
    public func eraseToAnyType() -> AnyType {
        AnyType(self)
    }
}
