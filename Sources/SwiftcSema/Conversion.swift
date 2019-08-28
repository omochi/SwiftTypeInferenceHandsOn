public enum Conversion : CustomStringConvertible, Hashable {
    case deepEquality
    // TODO: optional
    
    public var description: String {
        switch self {
        case .deepEquality: return "[deep equality]"
        }
    }
}
