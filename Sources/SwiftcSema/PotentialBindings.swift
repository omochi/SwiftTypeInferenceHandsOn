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
    
    // allowJoinMeet should be attributed in each PB?
    // ref: addPotentialBinding at CSBindings.cpp
    public mutating func add(_ binding: PotentialBinding) {
        let bindTy = binding.type
        // unresolved type, unbound generic type, allowJoinMeet...
        if binding.kind == .supertype,
            bindTy.typeVariables.isEmpty
        {
            if let index = (bindings.firstIndex { $0.kind == .supertype }) {
                var lastBinding = bindings[index]
                if let joinedTy = lastBinding.type.join(bindTy),
                    !(joinedTy is TopAnyType)
                {
                    var does = true
                    if let optTy = joinedTy as? OptionalType,
                        optTy.wrapped is TopAnyType
                    {
                        does = false
                    }
                    
                    if does {
                        lastBinding.type = joinedTy
                        bindings[index] = lastBinding
                        return
                    }
                }
            }
        }
        
        // lvalue
        
        guard isViableBinding(binding) else {
            return
        }
        
        bindings.append(binding)
    }
    
    private func isViableBinding(_ binding: PotentialBinding) -> Bool {
        // I still have a question
        // https://github.com/apple/swift/pull/19076
        return true
    }
}
