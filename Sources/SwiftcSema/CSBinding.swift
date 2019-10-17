import SwiftcType

extension ConstraintSystem {
    // ref: determineBestBindings at CSBindings.cpp
    public func determineBestBindings() -> PotentialBindings? {
        var bestOrNone: PotentialBindings? = nil
        var cache: Dictionary<TypeVariable, PotentialBindings> = [:]
        
        func isBetter(bindings: PotentialBindings) -> Bool {
            guard let _ = bestOrNone else {
                return true
            }
            
            // implement compare
            return false
        }
        
        for tv in typeVariables {
            guard tv.isFree(bindings: bindings) else {
                continue
            }
            
            if let bindings = potentialBindings(for: tv) {
                cache[tv] = bindings
            }
        }

        for tv in typeVariables {
            guard let bindings = cache[tv] else {
                continue
            }
            
            if isBetter(bindings: bindings) {
                bestOrNone = bindings
            }
        }
        
        return bestOrNone
    }
    
    // ref: getPotentialBindings at CSBindings.cpp
    public func potentialBindings(for tv: TypeVariable) -> PotentialBindings? {
        precondition(tv.isRepresentative(bindings: bindings))
        precondition(tv.fixedType(bindings: bindings) == nil)
        
        var result = PotentialBindings(typeVariable: tv)

        let constraints = gatherConstraints(involving: tv)
        
        var exactTypes: Set<AnyType> = []
        
        for csEnt in constraints {
            let constraint = csEnt.constraint
            switch constraint {
            case .bind,
                 .conversion:
                
                result.sources.append(constraint)
                
                guard let binding = potentialBinding(from: constraint, for: tv) else {
                    break
                }
                
                let bindTy = binding.type
                if exactTypes.insert(bindTy.eraseToAnyType()).inserted {
                    result.add(binding)
                    
                    // if isOptionalObject ...
                    
                    // closure void result potential
                }
                
            case .disjunction:
                // involves typevars
                break
            case .applicableFunction,
                 .bindOverload:
                // fully bound, inv tvs
                break
            }
        }
        
        // hasDML, hasNonDML...
        
        guard !result.bindings.isEmpty else {
            return nil
        }
        
        return result
    }
    
    // ref: getPotentialBindingForRelationalConstraint at CSBinding.cpp
    public func potentialBinding(from constraint: Constraint,
                                 for tv: TypeVariable)
        -> PotentialBinding?
    {
        let leftTy = constraint.left
        let rightTy = constraint.right
        
        if leftTy is TypeVariable, leftTy == rightTy {
            return nil
        }
        
        var type: Type
        let kind: PotentialBinding.Kind
        
        if leftTy == tv {
            type = rightTy
            kind = .subtype
        } else if rightTy == tv {
            type = leftTy
            kind = .supertype
        } else {
            // involves type variables check...
            return nil
        }
        
        guard let ty = checkTypeBindable(for: tv, type: type) else {
            return nil
        }
        type = ty
        
        // check optional wrapped typevar lvalue-ness
        // inout convert
        // lvalue convert
        // bind param adjustment
        
        return PotentialBinding(kind: kind, type: type, source: constraint.kind)
    }
    
    private func checkTypeBindable(for typeVariable: TypeVariable,
                                   type: Type) -> Type?
    {
        let type = simplify(type: type)
        
        // block vars
        if type is TypeVariable {
            return nil
        }
        
        if typeVariable.occurs(in: type) {
            return nil
        }
        
        // lvalue check
        
        // DMT check
        
        return type
    }
}
