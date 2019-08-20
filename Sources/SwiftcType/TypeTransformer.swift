import SwiftcBasic

public final class TypeTransformer : VisitorTransformerBase, TypeVisitor {
    public typealias VisitTarget = Type
    public typealias VisitResult = Type
    
    public let _transform: (Type) -> Type?
    
    public init(transform: @escaping (Type) -> Type?) {
        _transform = transform
    }
    
    public func transform(_ type: Type) -> Type? {
        _transform(type)
    }
    
    public func visitPrimitiveType(_ type: PrimitiveType) -> Type {
        return type
    }
    
    public func visitFunctionType(_ type: FunctionType) -> Type {
        let arg = process(type.parameter)
        let ret = process(type.result)
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
            return transformer.process(self)
        }
    }
}
