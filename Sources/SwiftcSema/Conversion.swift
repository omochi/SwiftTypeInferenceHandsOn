public enum Conversion : CustomStringConvertible, Hashable {
    case deepEquality
    case valueToOptional
    case optionalToOptional
    
    public var description: String {
        switch self {
        case .deepEquality: return "[deep equality]"
        case .valueToOptional: return "[value to optional]"
        case .optionalToOptional: return "[optional to optional]"
        }
    }
}
