import SwiftcBasic
import SwiftcType

extension ConstraintSystem {
    public func matchTypes(kind: Constraint.MatchKind,
                           left leftType: Type,
                           right rightType: Type,
                           options: MatchOptions) -> SolveResult
    {
        let leftType = simplify(type: leftType)
        let rightType = simplify(type: rightType)
        
        func ambiguous() -> SolveResult {
            if options.generateConstraintsWhenAmbiguous {
                let c = Constraint(kind: kind.asKind(), left: leftType, right: rightType)
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
                
                return matchTypesBind(typeVariable: variable,
                                      fixedType: fixedType)
            case .conversion:
                return ambiguous()
            }
        }
        
        return matchFixedTypes(kind: kind,
                               left: leftType,
                               right: rightType,
                               options: options)
    }
    
    private func matchTypesBind(typeVariable: TypeVariable,
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
    
    private func matchFixedTypes(kind: Constraint.MatchKind,
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
        
        if let leftType = leftType as? OptionalType,
            let rightType = rightType as? OptionalType
        {
            conversions.append(.deepEquality)
        }
        
        switch kind {
        case .conversion:
            if leftType is OptionalType,
                rightType is OptionalType
            {
                conversions.append(.optionalToOptional)
            }
            
            let leftOptNum = leftType.lookThroughAllOptionals().count
            let rightOptNum = rightType.lookThroughAllOptionals().count
            if leftOptNum < rightOptNum {
                conversions.append(.valueToOptional)
            }
        case .bind: break
        }
        
        
        func subKind(_ kind: Constraint.MatchKind, conversion: Conversion) -> Constraint.MatchKind {
            if conversion == .deepEquality { return .bind }
            else { return kind }
        }
        
        // 無いなら無理
        if conversions.isEmpty {
            return .failure
        }

        // 1つなら即時投入
        if conversions.count == 1 {
            let conversion = conversions[0]
            return simplify(kind: subKind(kind, conversion: conversion),
                            left: leftType, right: rightType,
                            conversion: conversion,
                            options: options)
        }

        // 2つ以上ならdisjunction
        let convCs: [Constraint] = conversions.map { (conv) in
            Constraint(kind: subKind(kind, conversion: conv),
                       left: leftType, right: rightType,
                       conversion: conv)
        }
        
        addDisjunctionConstraint(convCs)
        
        return .solved
    }
    
    // CSSimplify.cpp / matchFunctionTypes
    private func matchFunctionTypes(kind: Constraint.MatchKind,
                                    left leftType: FunctionType,
                                    right rightType: FunctionType,
                                    options: MatchOptions) -> SolveResult
    {
        let leftArg = leftType.parameter
        let rightArg = rightType.parameter
        
        let leftRet = leftType.result
        let rightRet = rightType.result
        
        print(leftArg)
        print(rightArg)
        print(leftRet)
        print(rightArg)
        
        let subKind: Constraint.MatchKind
        
        switch kind {
        case .bind: subKind = .bind
        case .conversion: subKind = .conversion
        }
        
        let subOptions = decompositionOptions(options)
        
        // Q2
        if leftArg == rightArg && leftRet == rightRet {
            return matchTypes(kind: subKind,
                              left: leftArg,
                              right: rightArg,
                              options: subOptions)
        }
        
        return .solved
    }
    
    internal func matchDeepEqualityTypes(left leftType: Type,
                                         right rightType: Type,
                                         options: MatchOptions) -> SolveResult
    {
        let subOptions = decompositionOptions(options)
        
        // Q1
        if leftType == rightType {
            return .solved
        }
        
        if let leftType = leftType as? OptionalType,
        let rightType = rightType as? OptionalType
        {
            return matchTypes(kind: .bind,
                              left: leftType.wrapped,
                              right: rightType.wrapped,
                              options: subOptions)
        }
        
        return .failure
    }
}
