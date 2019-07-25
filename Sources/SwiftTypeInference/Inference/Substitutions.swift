public struct Substitutions {
    public var items: [TypeVariable: Type]
    
    public init(items: [TypeVariable: Type] = [:]) {
        self.items = items
    }
    
    public func map(_ f: (Type) throws -> Type) rethrows -> Substitutions {
        let items = try self.items.mapValues { try $0.map(f) }
        return Substitutions(items: items)
    }
    
    public func map(from: Type, to: Type) -> Substitutions {
        map { (t) in
            if t == from {
                return to
            }
            return t
        }
    }
    
    public func apply(to type: Type) -> Type {
        type.map { (t) in
            if let tv = t as? TypeVariable,
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
