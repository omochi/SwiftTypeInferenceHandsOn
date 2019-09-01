import SwiftcType

public struct PotentialBindings : CustomStringConvertible {
    public var typeVariable: TypeVariable
    public var bindings: [PotentialBinding]
    public var sources: [Constraint]
    
    public init(typeVariable: TypeVariable,
                bindings: [PotentialBinding] = [],
                sources: [Constraint] = [])
    {
        self.typeVariable = typeVariable
        self.bindings = bindings
        self.sources = sources
    }
    
    public var description: String {
        let bindingsStr: String =
            "[" + bindings.map { $0.description }.joined(separator: ", ") + "]"
    
        return "\(typeVariable) <- \(bindingsStr)"
    }
    
    public func add(_ potentialBinding: PotentialBinding) {
        
    }
}
