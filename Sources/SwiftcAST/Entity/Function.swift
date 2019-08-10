import SwiftcType

public struct Function : CustomStringConvertible {
    public var name: String
    public var type: FunctionType
    
    public init(name: String,
                type: FunctionType)
    {
        self.name = name
        self.type = type
    }
    
    public var description: String {
        return "\(name): \(type)"
    }
}
