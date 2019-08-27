public enum Conversion : CustomStringConvertible, Hashable {
    case deepEquality
    
    public var description: String {
        switch self {
        case .deepEquality: return "[deep equality]"
        }
    }
}
