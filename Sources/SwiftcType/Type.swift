import Foundation
import SwiftcBasic

public protocol Type : CustomStringConvertible {
    func isEqual(_ other: Type) -> Bool
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
