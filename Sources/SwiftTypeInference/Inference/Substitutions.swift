public struct Substitutions {
    public var items: [TypeVariable: AnyType]
    
    public init(items: [TypeVariable: AnyType] = [:]) {
        self.items = items
    }
    
    public func map(_ f: (AnyType) throws -> AnyType) rethrows -> Substitutions {
        let items = try self.items.mapValues { try $0.map(f) }
        return Substitutions(items: items)
    }
    
    public func map(from: AnyType, to: AnyType) -> Substitutions {
        map { (t) in
            if t == from {
                return to
            }
            return t
        }
    }
    
    public func apply<X: Type>(to type: X) -> AnyType {
        type.map { (t) in
            if let tv = t.asVariable(),
                let s = items[tv]
            {
                return s
            }
            return t
        }
    }
    
    public func apply(to constraint: Constraint) -> Constraint {
        constraint.map { apply(to: $0) }
    }
}
