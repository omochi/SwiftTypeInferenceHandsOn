import SwiftcBasic
import SwiftcType

public enum Constraint : CustomStringConvertible {
    public enum Kind : Hashable {
        case bind
    }
    
    case bind(left: Type, right: Type)
    
    public var kind: Kind {
        switch self {
        case .bind: return .bind
        }
    }
    
    public var description: String {
        switch self {
        case .bind(left: let left, right: let right):
            return "\(left) :bind: \(right)"
        }
    }
    
    public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
        switch lhs {
        case .bind(left: let al, right: let ar):
            guard case .bind(left: let bl, let br) = rhs else {
                return false
            }
            return al == bl && ar == br
        }
    }

}

