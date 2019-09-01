public final class TypeJoiner : TypeVisitor {
    public typealias VisitTarget = Type
    public typealias VisitResult = Type?
    public let left: Type
    
    public init(left: Type) {
        self.left = left
    }
    
    public func visitPrimitiveType(_ right: PrimitiveType) throws -> Type? {
        precondition(left != right)
        
        return TopAnyType()
    }
    
    public func visitFunctionType(_ right: FunctionType) throws -> Type? {
        guard let left = left as? FunctionType else {
            return TopAnyType()
        }
        
        if left.parameter != right.parameter {
            return nil
        }
        
        guard let result = left.result.join(right.result) else {
            return nil
        }
        
        return FunctionType(parameter: left.parameter, result: result)
    }
    
    public func visitOptionalType(_ right: OptionalType) throws -> Type? {
        if let joined = Self.joinOptional(left: left, right: right) {
            return joined
        }
        
        return nil
    }
    
    public func visitTypeVariable(_ right: _TypeVariable) throws -> Type? {
        return nil
    }
    
    public func visitTopAnyType(_ right: TopAnyType) throws -> Type? {
        if left is FunctionType {
            return nil
        }
        
        return TopAnyType()
    }
    
    private static func joinOptional(left: Type, right: Type) -> Type? {
        guard left is OptionalType || right is OptionalType else {
            return nil
        }
        
        var left = left
        var right = right
        
        if let lo = left as? OptionalType {
            left = lo.wrapped
        }
        if let ro = right as? OptionalType {
            right = ro.wrapped
        }
        
        guard let join = left.join(right) else {
            return nil
        }
        
        return OptionalType(join)
    }
}

extension Type {
    public func join(_ right: Type) -> Type? {
        let left = self
        
        if left == right {
            return self
        }
        
        func doIt() -> Type? {
            return try! TypeJoiner(left: left).visit(right)
        }
        func swapIt() -> Type? {
            return try! TypeJoiner(left: right).visit(left)
        }
        
        if left is OptionalType {
            return swapIt()
        }
        
        if right is OptionalType {
            return doIt()
        }
        
        if left is TopAnyType {
            return swapIt()
        }
        
        if right is TopAnyType {
            return doIt()
        }
        
        return try! TypeJoiner(left: left).visit(right)
    }
}
