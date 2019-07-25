import Foundation

public protocol Type : CustomStringConvertible {
    func equals(to other: Type) -> Bool
    
    func map(_ f: (Type) throws -> Type) rethrows -> Type
}

//public func ==(a: Type, b: Type) -> Bool {
//    return a.equals(to: b)
//}

public protocol EquatableType : Type, Equatable {
}

extension EquatableType {
    public func equals(to other: Type) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}
