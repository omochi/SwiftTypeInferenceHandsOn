import SwiftcType

extension ConstraintSystem {
    public func determineBestBindings() -> PotentialBindings? {
        var best: PotentialBindings? = nil
        var cache: Dictionary<TypeVariable, PotentialBindings> = [:]
        
        for tv in typeVariables {
            // TODO
            guard case .fixed(.none) = bindings.binding(for: tv) else {
                continue
            }
        }
    }
    
    public func potentialBindings(for tv: TypeVariable) -> PotentialBindings {
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
        
        return result
    }
    
    // TOOD: add to sources
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