import Foundation

// left == right
public struct Constraint {
    public var left: AnyType
    public var right: AnyType
    
    public init<L : Type, R : Type>(
        left: L,
        right: R)
    {
        self.left = left.asAnyType()
        self.right = right.asAnyType()
    }
    
    public func reversed() -> Constraint {
        return Constraint(left: right, right: left)
    }
    
    public func map(_ f: (AnyType) throws -> AnyType) rethrows -> Constraint {
        let left = try self.left.map(f)
        let right = try self.right.map(f)
        return Constraint(left: left, right: right)
    }
}
