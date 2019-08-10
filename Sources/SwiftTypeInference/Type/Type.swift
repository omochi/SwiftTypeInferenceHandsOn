import Foundation

public protocol Type : CustomStringConvertible {
    func isEqual(_ other: Type) -> Bool
    
    func map(_ f: (Type) throws -> Type) rethrows -> Type
}

public func ==(a: Type, b: Type) -> Bool {
    return a.isEqual(b)
}

public protocol _EquatableType : Type, Equatable {}

extension _EquatableType {
    public func isEqual(_ other: Type) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return Equatables.isEqual(self, other)
    }
}

public protocol _LeafType : Type {}

extension _LeafType {
    public func map(_ f: (Type) throws -> Type) rethrows -> Type {
        try f(self)
    }
}
