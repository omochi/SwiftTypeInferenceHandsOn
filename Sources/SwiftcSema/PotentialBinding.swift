import SwiftcType

public struct PotentialBinding : CustomStringConvertible {
    public enum Kind {
        case exact
        case supertype
        case subtype
    }

    public var kind: Kind
    public var type: Type
    public var source: Constraint.Kind
    
    public init(kind: Kind,
                type: Type,
                source: Constraint.Kind)
    {
        self.kind = kind
        self.type = type
        self.source = source
    }
    
    public var description: String {
        func kindStr() -> String {
            switch kind {
            case .exact: return "exact"
            case .subtype: return "subtype of"
            case .supertype: return "supertype of"
            }
        }
        
        return "\(kindStr()) \(type)"
    }
    
}
