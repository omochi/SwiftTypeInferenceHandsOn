public struct FunctionType : Type {
    public var arguments: [Type]
    public var result: Type

    public init(arguments: [Type],
                result: Type)
    {
        self.arguments = arguments
        self.result = result
    }
    
    public init(argument: Type, result: Type) {
        self.init(arguments: [argument], result: result)
    }

    public var description: String {
        let args = arguments.map { $0.description }.joined(separator: ", ")
        return "(\(args)) -> \(result)"
    }
    
    public func equals(to other: Type) -> Bool {
        guard let other = other as? FunctionType,
            self.arguments.elementsEqual(other.arguments, by: { (a, b) in a.equals(to: b) }),
            self.result.equals(to: other.result) else
        {
            return false
        }
        
        return true
    }
    
    public func map(_ f: (Type) throws -> Type) rethrows -> Type {
        let arguments = try self.arguments.map { try $0.map(f) }
        let result = try self.result.map(f)
        let ft = FunctionType(arguments: arguments,
                              result: result)
        return try f(ft)
    }
}
