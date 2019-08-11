public struct FunctionType : _EquatableType {
    private struct Eq : Equatable {
        public var argument: TypeEquatableAdapter
        public var result: TypeEquatableAdapter
        public init(_ x: FunctionType) {
            argument = x.argument.wrapInEquatable()
            result = x.result.wrapInEquatable()
        }
    }
    
    public var argument: Type
    public var result: Type

    public init(argument: Type,
                result: Type)
    {
        self.argument = argument
        self.result = result
    }
    
    public var description: String {
        "(\(argument)) -> \(result)"
    }
    
    public static func == (lhs: FunctionType, rhs: FunctionType) -> Bool {
         Eq(lhs) == Eq(rhs)
    }
}
