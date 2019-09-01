import SwiftcBasic
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
        var ts: Set<TypeVariable> = []
        _ = find { (type) in
            if let type = type as? TypeVariable {
                ts.insert(type)
            }
            return false
        }
        return ts
    }
    
    // DependentMemberType...
    public var inferableTypeVariables: Set<TypeVariable> {
        var ts: Set<TypeVariable> = []
        func preWalk(type: Type) -> PreWalkResult<Type> {
            // if dependent member type
//            if type is DependentMemberType {
//                return .skipChildren(type)
//            }
            
            if let tv = type as? TypeVariable {
                ts.insert(tv)
            }
            return .continue(type)
        }
        _ = try! walk(preWalk: preWalk)
        return ts
    }
}
