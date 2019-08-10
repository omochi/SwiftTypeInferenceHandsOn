public struct FunctionType : _EquatableType, _LeafType {
    private struct Eq : Equatable {
        public var arguments: [TypeEquatableAdapter]
        public var result: TypeEquatableAdapter
        public init(_ x: FunctionType) {
            arguments = x.arguments.map { TypeEquatableAdapter($0) }
            result = TypeEquatableAdapter(x.result)
        }
    }
    
    public var arguments: [Type]
    public var result: Type

    public init(arguments: [Type],
                result: Type)
    {
        self.arguments = arguments
        self.result = result
    }
    
    public var description: String {
        let args = arguments.map { $0.description }.joined(separator: ", ")
        return "(\(args)) -> \(result)"
    }
    
    public static func == (lhs: FunctionType, rhs: FunctionType) -> Bool {
        return Eq(lhs) == Eq(rhs)
    }
    
    public func map(_ f: (Type) throws -> Type) rethrows -> Type {
        let arguments = try self.arguments.map { try $0.map(f) }
        let result = try self.result.map(f)
        let ft = FunctionType(arguments: arguments,
                              result: result)
        return try f(ft)
    }
}
