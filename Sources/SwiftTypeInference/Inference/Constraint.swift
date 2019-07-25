import Foundation

// left == right
public struct Constraint {
    public var left: Type
    public var right: Type
    
    public init(
        left: Type,
        right: Type)
    {
        self.left = left
        self.right = right
    }
    
    public func reversed() -> Constraint {
        return Constraint(left: right, right: left)
    }
    
    public func map(_ f: (Type) throws -> Type) rethrows -> Constraint {
        let left = try self.left.map(f)
        let right = try self.right.map(f)
        return Constraint(left: left, right: right)
    }
}
