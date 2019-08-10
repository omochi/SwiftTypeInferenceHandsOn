public struct TypeEquatableAdapter : Equatable, CustomStringConvertible {
    private var value: Type
    
    public init(_ value: Type) {
        self.value = value
    }
    
    public static func ==(a: TypeEquatableAdapter,
                          b: TypeEquatableAdapter) -> Bool
    {
        a.value == b.value
    }

    public var description: String { value.description }
}

extension Type {
    public func wrapInEquatable() -> TypeEquatableAdapter {
        TypeEquatableAdapter(self)
    }
}
