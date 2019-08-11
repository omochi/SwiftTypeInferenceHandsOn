import SwiftcBasic
import SwiftcType

public final class Constraint {
    public enum Kind {
        case bind
    }
    
    public enum Descriptor : CustomStringConvertible {
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
    }
    
    public let descriptor: Descriptor
    public var isActive: Bool
    
    public init(descriptor: Descriptor) {
        self.descriptor = descriptor
        self.isActive = false
    }
}
