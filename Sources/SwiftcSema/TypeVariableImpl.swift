import SwiftcType

public final class TypeVariable : _TypeVariable
{
    private let _id: Int
    
    public internal(set) var representative: TypeVariable {
        get { _representative! }
        set { _representative = newValue }
    }
    public internal(set) var _representative: TypeVariable!
    
    public internal(set) var equivalentTypeVariables: [TypeVariable] = []
    public internal(set) var fixedType: Type? = nil
    
    public init(id: Int)
    {
        _id = id
        super.init()
        _representative = self
    }
    
    // explicit retain cycle destruction
    public func release() {
        _representative = nil
    }

    public override var id: Int { _id }
    
    public var isRepresentative: Bool { representative == self }
    
    public func occurs(in type: Type) -> Bool {
        type.typeVariables.contains(self)
    }
}

extension Type {
    public var typeVariables: Set<TypeVariable> {
        var ts: Set<TypeVariable> = Set()
        func add(type: Type) -> Bool {
            if let type = type as? TypeVariable {
                ts.insert(type)
            }
            return false
        }
        _ = find(add)
        return ts
    }
}
