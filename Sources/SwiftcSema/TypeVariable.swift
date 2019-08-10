import SwiftcType

public final class TypeVariable :
    _EquatableType, _LeafType,
    Comparable,
    Hashable
{
    public let id: Int
    
    public var representative: TypeVariable { _representative! }
    public internal(set) var _representative: TypeVariable!
    
    public internal(set) var equivalentTypeVariables: [TypeVariable] = []
    public internal(set) var fixedType: Type? = nil
    
    public init(id: Int)
    {
        self.id = id
        
       _representative = self
    }
    
    // explicit retain cycle destruction
    public func release() {
        _representative = nil
    }
    
    public var description: String {
        return "$T\(id)"
    }
    
    public static func ==(a: TypeVariable, b: TypeVariable) -> Bool {
        return a.id == b.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func <(a: TypeVariable, b: TypeVariable) -> Bool {
        return a.id < b.id
    }
    
    public var isRepresentative: Bool { representative == self }
}
