public struct FunctionType : Type {
    public var arguments: [AnyType]
    public var result: AnyType

    public init<R: Type>(arguments: [AnyType],
                         result: R)
    {
        self.arguments = arguments
        self.result = result.asAnyType()
    }
    
    public init<A: Type, R: Type>(argument: A, result: R) {
        self.init(arguments: [argument.asAnyType()], result: result)
    }

    public var description: String {
        let args = arguments.map { $0.description }.joined(separator: ", ")
        return "(\(args)) -> \(result)"
    }
    
    public func map(_ f: (AnyType) throws -> AnyType) rethrows -> AnyType {
        let arguments = try self.arguments.map { try $0.map(f) }
        let result = try self.result.map(f)
        let ft = FunctionType(arguments: arguments,
                              result: result)
        return try f(ft.asAnyType())
    }
}
