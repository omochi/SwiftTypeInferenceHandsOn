import SwiftcType

public struct TypeVariableBindings {
    public enum Binding {
        case fixed(Type?)
        case equivalent(TypeVariable)
    }
    
    public var items: [TypeVariable: Binding] = [:]
    
    public mutating func merge(type1: TypeVariable,
                               type2: TypeVariable)
    {
        precondition(type1.isRepresentative(bindings: self))
        precondition(type1.fixedType(bindings: self) == nil)
        precondition(type2.isRepresentative(bindings: self))
        precondition(type2.fixedType(bindings: self) == nil)
        
        if type1 == type2 {
            return
        }
        
        var type1 = type1
        var type2 = type2
        
        if type1 > type2 {
            swap(&type1, &type2)
        }
        
        let newEqs = type2.equivalentTypeVariables(bindings: self)
        for newEq in newEqs {
            items[newEq] = .equivalent(type1)
        }
    }
    
    public mutating func assign(variable: TypeVariable,
                                type: Type)
    {
        precondition(variable.isRepresentative(bindings: self))
        precondition(variable.fixedType(bindings: self) == nil)
        precondition(!(type is TypeVariable))
        
        items[variable] = .fixed(type)
    }
}

extension TypeVariable {
    public func isRepresentative(bindings: TypeVariableBindings) -> Bool {
        representative(bindings: bindings) == self
    }
    
    public func representative(bindings: TypeVariableBindings) -> TypeVariable {
        switch bindings.items[self]! {
        case .fixed:
            return self
        case .equivalent(let rep):
            return rep
        }
    }
    
    public func fixedType(bindings: TypeVariableBindings) -> Type? {
        switch bindings.items[self]! {
        case .fixed(let ft):
            return ft
        case .equivalent(let rep):
            return rep.fixedType(bindings: bindings)
        }
    }
    
    public func fixedOrRepresentative(bindings: TypeVariableBindings) -> Type {
        switch bindings.items[self]! {
        case .fixed(let ft):
            if let ft = ft {
                return ft
            }
            return self
        case .equivalent(let rep):
            return rep.fixedOrRepresentative(bindings: bindings)
        }
    }
    
    public func equivalentTypeVariables(bindings: TypeVariableBindings) -> Set<TypeVariable> {
        var ret = Set<TypeVariable>()
        for (tv, b) in bindings.items {
            switch b {
            case .fixed:
                if tv == self { ret.insert(tv) }
            case .equivalent(let rep):
                if rep == self { ret.insert(tv) }
            }
        }
        return ret
    }
}

extension Type {
    public func simplify(bindings: TypeVariableBindings) -> Type {
        transform { (type) in
            if let tv = type as? TypeVariable {
                var type = tv.fixedOrRepresentative(bindings: bindings)
                if !(type is TypeVariable) {
                    type = type.simplify(bindings: bindings)
                }
                return type
            }
             
            return nil
        }
    }
}
