import Foundation

public struct Constraint {
    public var left: Type
    public var right: Type
    
    public init(left: Type,
                right: Type)
    {
        self.left = left
        self.right = right
    }
}
