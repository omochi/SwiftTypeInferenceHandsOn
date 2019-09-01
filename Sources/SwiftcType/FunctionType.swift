public struct FunctionType : _EquatableType {
    private struct Eq : Hashable {
        public var parameter: AnyType
        public var result: AnyType
        public init(_ x: FunctionType) {
            parameter = x.parameter.eraseToAnyType()
            result = x.result.eraseToAnyType()
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
    
    public func print(options: TypePrintOptions) -> String {
        "(\(parameter)) -> \(result)"
    }
    
    public static func == (lhs: FunctionType, rhs: FunctionType) -> Bool {
         Eq(lhs) == Eq(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Self.self))
        hasher.combine(Eq(self))
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : TypeVisitor {
        try visitor.visitFunctionType(self)
    }
    
}
