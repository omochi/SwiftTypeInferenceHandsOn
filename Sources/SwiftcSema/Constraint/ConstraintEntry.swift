public final class ConstraintEntry {
    public let constraint: Constraint
    public var isActive: Bool
    
    public init(_ constraint: Constraint) {
        self.constraint = constraint
        self.isActive = false
    }
}
