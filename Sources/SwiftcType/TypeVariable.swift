import SwiftcBasic

open class _TypeVariable :
    _EquatableType,
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
    
    public func accept<V>(visitor: V) -> V.VisitResult where V : TypeVisitor {
        visitor.visitTypeVariable(self)
    }
    
    public static func ==(a: _TypeVariable, b: _TypeVariable) -> Bool {
        return a.id == b.id
    }
    
    public static func <(a: _TypeVariable, b: _TypeVariable) -> Bool {
        return a.id < b.id
    }
}
