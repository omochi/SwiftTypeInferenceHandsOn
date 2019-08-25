import Foundation
import SwiftcBasic

public protocol Type : CustomStringConvertible {
    func isEqual(_ other: Type) -> Bool
    
    func hash(into hasher: inout Hasher)
    
    func accept<V: TypeVisitor>(visitor: V) throws -> V.VisitResult
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
        return ExplicitDispatch.isEqual(self, other)
    }
}
