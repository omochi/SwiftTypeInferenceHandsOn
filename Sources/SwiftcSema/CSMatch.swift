import SwiftcBasic
import SwiftcType

extension ConstraintSystem {
    public func matchTypes(kind: Constraint.Kind,
                           left: Type,
                           right: Type,
                           options: MatchOptions) -> SolveResult
    {
        let left = simplify(type: left)
        let right = simplify(type: right)
        
        let leftVar = left as? TypeVariable
        let rightVar = right as? TypeVariable
        
        if leftVar != nil || rightVar != nil {
            if let left = leftVar, let right = rightVar {
                return matchTypeVariables(left: left,
                                          right: right,
                                          kind: kind)
            }
            
            var variable: TypeVariable!
            var type: Type!
            
            if let left = leftVar {
                variable = left
                type = right
            } else {
                variable = rightVar!
                type = left
            }
            
            return matchTypeVariableAndFixedType(kind: kind,
                                                 variable: variable,
                                                 type: type)
        }
        
        return matchFixedTypes(kind: kind,
                               type1: left, type2: right,
                               options: options)
    }
    
    private func matchTypeVariables(left: TypeVariable,
                                    right: TypeVariable,
                                    kind: Constraint.Kind) -> SolveResult
    {
        precondition(left.isRepresentative(bindings: bindings))
        precondition(right.isRepresentative(bindings: bindings))
        
        if left == right {
            return .solved
        }
        
        switch kind {
        case .bind:
            mergeEquivalence(type1: left, type2: right)
            return .solved
        case .applicableFunction,
             .bindOverload:
            preconditionFailure("invalid kind: \(kind)")
        }
    }
    
    private func matchTypeVariableAndFixedType(kind: Constraint.Kind,
                                               variable: TypeVariable,
                                               type: Type) -> SolveResult
    {
        precondition(variable.isRepresentative(bindings: bindings))
        switch kind {
        case .bind:
            if variable.occurs(in: type) {
                return .failure
            }
            
            assignFixedType(variable: variable, type: type)
            return .solved
        case .applicableFunction,
             .bindOverload:
            preconditionFailure("invalid kind: \(kind)")
        }
    }
    
    private func matchFixedTypes(kind: Constraint.Kind,
                                 type1: Type,
                                 type2: Type,
                                 options: MatchOptions) -> SolveResult
    {
        precondition(!(type1 is TypeVariable))
        precondition(!(type2 is TypeVariable))
        
        switch kind {
        case .bind:
            if let type1 = type1 as? PrimitiveType {
                guard let type2 = type2 as? PrimitiveType else {
                    return .failure
                }
                
                if type1.name == type2.name {
                    return .solved
                } else {
                    return .failure
                }
            }
            
            if let type1 = type1 as? FunctionType {
                guard let type2 = type2 as? FunctionType else {
                    return .failure
                }
                
                return matchFunctionTypes(kind: kind,
                                          type1: type1, type2: type2,
                                          options: options)
            }
            
            unimplemented()
        case .applicableFunction,
             .bindOverload:
            preconditionFailure("invalid kind: \(kind)")
        }
    }
    
    private func matchFunctionTypes(kind: Constraint.Kind,
                                    type1: FunctionType,
                                    type2: FunctionType,
                                    options: MatchOptions) -> SolveResult
    {
        let arg1 = type1.parameter
        let arg2 = type2.parameter
        
        let ret1 = type1.result
        let ret2 = type2.result
        
        var isAmbiguous = false
        
        switch kind {
        case .bind:
            switch matchTypes(kind: kind,
                              left: arg1, right: arg2,
                              options: options)
            {
            case .failure: return .failure
            case .ambiguous:
                isAmbiguous = true
                break
            case .solved: break
            }
            
            switch matchTypes(kind: kind,
                              left: ret1, right: ret2,
                              options: options)
            {
            case .failure: return .failure
            case .ambiguous:
                isAmbiguous = true
                break
            case .solved: break
            }
            
            if isAmbiguous {
                return .ambiguous
            } else {
                return .solved
            }
        case .applicableFunction,
             .bindOverload:
            preconditionFailure("invalid kind: \(kind)")
        }
    }
}
