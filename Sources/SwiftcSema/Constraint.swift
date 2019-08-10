import Foundation
import SwiftcType

public enum Constraint {
    public enum Kind {
        case bind
    }
    
    case bind(left: Type, right: Type)
    
    public var kind: Kind {
        switch self {
        case .bind: return .bind
        }
    }
}
