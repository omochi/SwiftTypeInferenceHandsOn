import Foundation

public struct TypeVariable : EquatableType, Hashable {
    public var id: Int
    
    public init(id: Int) {
        self.id = id
    }
    
    public var description: String {
        return "$t\(id)"
    }
    
    public func map(_ f: (Type) throws -> Type) rethrows -> Type {
        try f(self)
    }
}
