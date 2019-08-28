import SwiftcBasic
import SwiftcType

extension ConstraintSystem {
    public func matchTypes(kind: Constraint.Kind,
                           left leftType: Type,
                           right rightType: Type,
                           options: MatchOptions) -> SolveResult
    {
        let leftType = simplify(type: leftType)
        let rightType = simplify(type: rightType)
        
        func ambiguous() -> SolveResult {
            if options.generateConstraintsWhenAmbiguous {
                let c = Constraint(kind: kind, left: leftType, right: rightType)
                _addConstraintEntry(ConstraintEntry(c))
                return .solved
            }
            return .ambiguous
        }
        
        let leftVarOrNone = leftType as? TypeVariable
        let rightVarOrNone = rightType as? TypeVariable
        
        if leftVarOrNone != nil || rightVarOrNone != nil {
            if let leftVar = leftVarOrNone,
                let rightVar = rightVarOrNone
            {
                if leftVar == rightVar {
                    return .solved
                }
            }
            
            switch kind {
            case .bind:
                if let leftVar = leftVarOrNone,
                    let rightVar = rightVarOrNone
                {
                    mergeEquivalence(type1: leftVar, type2: rightVar)
                    return .solved
                }
                
                let variable: TypeVariable
                let fixedType: Type
                if let leftVar = leftVarOrNone {
                    variable = leftVar
                    fixedType = rightType
                } else {
                    variable = rightVarOrNone!
                    fixedType = leftType
                }
                
                return matchTypesBind(kind: kind,
                                      typeVariable: variable,
                                      fixedType: fixedType)
            case .conversion:
                return ambiguous()
            case .applicableFunction,
                 .bindOverload,
                 .disjunction:
                preconditionFailure("invalid kind: \(kind)")
            }
        }
        
        return matchFixedTypes(kind: kind,
                               left: leftType,
                               right: rightType,
                               options: options)
    }
    
    private func matchTypesBind(kind: Constraint.Kind,
                                typeVariable: TypeVariable,
                                fixedType: Type) -> SolveResult
    {
        precondition(typeVariable.isRepresentative(bindings: bindings))
        
        if typeVariable.occurs(in: fixedType) {
            return .failure
        }
        
        assignFixedType(for: typeVariable, fixedType)
        return .solved
    }
    
    internal func decompositionOptions(_ options: MatchOptions) -> MatchOptions {
        var options = options
        options.generateConstraintsWhenAmbiguous = true
        return options
    }
    
    private func matchFixedTypes(kind: Constraint.Kind,
                                 left leftType: Type,
                                 right rightType: Type,
                                 options: MatchOptions) -> SolveResult
    {
        precondition(!(leftType is TypeVariable))
        precondition(!(rightType is TypeVariable))
        
        var conversions: [Conversion] = []
        
        if let leftType = leftType as? PrimitiveType,
            let rightType = rightType as? PrimitiveType
        {
            if leftType.name == rightType.name {
                conversions.append(.deepEquality)
            }
        }
        
        if let leftType = leftType as? FunctionType,
        let rightType = rightType as? FunctionType
        {
            return matchFunctionTypes(kind: kind,
                                      left: leftType,
                                      right: rightType,
                                      options: options)
        }
        
        // TODO: optional handling
        
        if conversions.isEmpty {
            return .failure
        }
        
        func subKind(_ kind: Constraint.Kind, conversion: Conversion) -> Constraint.Kind {
            if conversion == .deepEquality { return .bind }
            else { return kind }
        }
        
        if conversions.count == 1 {
            // 1つなら即時投入
            let conversion = conversions[0]
            return simplify(conversion: conversion,
                            left: leftType, right: rightType,
                            kind: subKind(kind, conversion: conversion),
                            options: options)
        }

        // TODO: disjunction
        fatalError()
        
    }
    
    private func matchFunctionTypes(kind: Constraint.Kind,
                                    left leftType: FunctionType,
                                    right rightType: FunctionType,
                                    options: MatchOptions) -> SolveResult
    {
        let leftArg = leftType.parameter
        let rightArg = rightType.parameter
        
        let leftRet = leftType.result
        let rightRet = rightType.result
        
        let subKind: Constraint.Kind
        
        switch kind {
        case .bind: subKind = .bind
        case .conversion: subKind = .conversion
        case .applicableFunction,
             .bindOverload,
             .disjunction:
            preconditionFailure("invalid kind: \(kind)")
        }
        
        let subOptions = decompositionOptions(options)
        
        switch matchTypes(kind: subKind,
                          left: leftArg, right: rightArg,
                          options: subOptions) {
        case .failure: return .failure
        case .ambiguous: preconditionFailure()
        case .solved: break
        }
        
        switch matchTypes(kind: subKind,
                          left: rightRet, right: leftRet,
                          options: subOptions) {
        case .failure: return .failure
        case .ambiguous: preconditionFailure()
        case .solved: break
        }
        
        return .solved
    }
    
    internal func matchDeepEqualityTypes(left leftType: Type,
                                        right rightType: Type) -> SolveResult
    {
        if let leftType = leftType as? PrimitiveType,
            let rightType = rightType as? PrimitiveType
        {
            if leftType.name != rightType.name {
                return .failure
            }
            
            return .solved
        }
        
        return .failure
    }
}
