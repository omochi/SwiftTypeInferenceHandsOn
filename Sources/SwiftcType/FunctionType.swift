public struct FunctionType : _EquatableType {
    private struct Eq : Equatable {
        public var parameter: TypeEquatableAdapter
        public var result: TypeEquatableAdapter
        public init(_ x: FunctionType) {
            parameter = x.parameter.wrapInEquatable()
            result = x.result.wrapInEquatable()
        }
    }
    
    public var parameter: Type
    public var result: Type

    public init(parameter: Type,
                result: Type)
    {
        self.parameter = parameter
        self.result = result
    }
    
    public var description: String {
        "(\(parameter)) -> \(result)"
    }
    
    public static func == (lhs: FunctionType, rhs: FunctionType) -> Bool {
         Eq(lhs) == Eq(rhs)
    }
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : TypeVisitor {
        visitor.visitFunctionType(self)
    }
    
}
