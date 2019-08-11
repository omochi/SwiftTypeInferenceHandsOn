public final class TypeTransformer : TypeVisitor {
    public typealias VisitResult = Type
    
    public let transform: (Type) -> Type?
    
    public init(transform: @escaping (Type) -> Type?) {
        self.transform = transform
    }
    
    public func process(type: Type) -> Type {
        if let type = transform(type) {
            return type
        }
        
        return visit(type: type)
    }
    
    public func visitPrimitiveType(_ type: PrimitiveType) -> Type {
        return type
    }
    
    public func visitFunctionType(_ type: FunctionType) -> Type {
        let arg = process(type: type.parameter)
        let ret = process(type: type.result)
        return FunctionType(parameter: arg, result: ret)
    }
    
    public func visitTypeVariable(_ type: _TypeVariable) -> Type {
        return type
    }
}

extension Type {
    /**
     型を巡回して書き換える。
     親に対して先にfが呼び出される。
     fが型を返すとそのノードの書き換えが起き、子の巡回はされない。
     fがnilを返した場合は、子に対して再帰的に巡回する。
    */
    public func transform(_ f: (Type) -> Type?) -> Type {
        withoutActuallyEscaping(f) { (f) in
            let transformer = TypeTransformer(transform: f)
            return transformer.process(type: self)
        }
    }
}
