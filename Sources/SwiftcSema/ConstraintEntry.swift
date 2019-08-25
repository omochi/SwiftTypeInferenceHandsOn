import SwiftcBasic

public final class ConstraintEntry : IdentityEquatable, CustomStringConvertible {
    public let constraint: Constraint
    public var isActive: Bool
    
    public init(_ constraint: Constraint) {
        self.constraint = constraint
        self.isActive = false
    }
    
    public var description: String {
        constraint.description
    }
}
