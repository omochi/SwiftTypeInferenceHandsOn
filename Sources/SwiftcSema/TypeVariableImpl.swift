import SwiftcType

public final class TypeVariable : _TypeVariable
{
    private let _id: Int
    
    public init(id: Int)
    {
        _id = id
        super.init()
    }
    
    public override var id: Int { _id }
    
    public func occurs(in type: Type) -> Bool {
        type.typeVariables.contains(self)
    }
}

extension Type {
    public var typeVariables: Set<TypeVariable> {
        var ts: Set<TypeVariable> = Set()
        _ = find { (type) in
            if let type = type as? TypeVariable {
                ts.insert(type)
            }
            return false
        }
        return ts
    }
}
