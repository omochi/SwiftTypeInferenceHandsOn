public struct TypeEquatableAdapter : Equatable {
    private var value: Type
    
    public init(_ value: Type) {
        self.value = value
    }
    
    public static func ==(a: TypeEquatableAdapter,
                          b: TypeEquatableAdapter) -> Bool
    {
        return a.value == b.value
    }
}
