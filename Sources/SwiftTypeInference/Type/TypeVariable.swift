import Foundation

public struct TypeVariable : Type {
    public var id: Int
    
    public init(id: Int) {
        self.id = id
    }
    
    public var description: String {
        return "$t\(id)"
    }
}
