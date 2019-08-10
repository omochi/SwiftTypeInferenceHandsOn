import SwiftcBasic

open class _TypeVariable :
    _EquatableType,
    _LeafType,
    Hashable,
    Comparable
{
    public init() {}
    
    public var description: String {
        return "$T\(id)"
    }
    
    open var id: Int { abstract() }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func ==(a: _TypeVariable, b: _TypeVariable) -> Bool {
        return a.id == b.id
    }
    
    public static func <(a: _TypeVariable, b: _TypeVariable) -> Bool {
        return a.id < b.id
    }
}
