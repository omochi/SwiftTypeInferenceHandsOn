import SwiftcBasic
import SwiftcType

extension ConstraintSystem {
    public func simplify(constraint: Constraint) -> SolveResult {
        let options = MatchOptions()
        switch constraint {
        case .bind(left: let left, right: let right, conversion: let conversion),
             .conversion(left: let left, right: let right, conversion: let conversion):
            let kind = constraint.kind.toMatchKind()!
            
            if let conversion = conversion {
                return simplify(kind: kind,
                                left: left, right: right,
                                conversion: conversion,
                                options: options)
            }
            
            return matchTypes(kind: kind,
                              left: left, right: right,
                              options: options)
        case .applicableFunction(left: let left, right: let right):
            return simplifyApplicableFunctionConstraint(left: left, right: right,
                                                        options: options)
        case .bindOverload(left: let left, choice: let choice, location: let location):
            resolveOverload(boundType: left, choice: choice, location: location)
            return .solved
        case .disjunction:
            return .ambiguous
        }
    }
    
    public func simplify(kind: Constraint.MatchKind,
                         left leftType: Type,
                         right rightType: Type,
                         conversion: Conversion,
                         options: MatchOptions) -> SolveResult {
        switch _simplify(kind: kind,
                         left: leftType, right: rightType,
                         conversion: conversion,
                         options: options) {
        case .solved:
            let rel = TypeConversionRelation(conversion: conversion, left: leftType, right: rightType)
            typeConversionRelations.append(rel)
            return .solved
        case .ambiguous: return .ambiguous
        case .failure: return .failure
        }
    }
    
    private func _simplify(kind: Constraint.MatchKind,
                           left leftType: Type,
                           right rightType: Type,
                           conversion: Conversion,
                           options: MatchOptions) -> SolveResult
    {
        precondition(!(leftType is TypeVariable))
        precondition(!(rightType is TypeVariable))
        
        let subOptions = decompositionOptions(options)
        
        switch conversion {
        case .deepEquality:
            return matchDeepEqualityTypes(left: leftType, right: rightType,
                                          options: options)
        case .valueToOptional:
            // <Q09 hint="see optionalToOptional" />
            if let rightType = rightType as? OptionalType {
                return matchTypes(kind: kind,
                                  left: leftType,
                                  right: rightType.wrapped,
                                  options: subOptions)
            }
            return .failure
        case .optionalToOptional:
            if let leftType = leftType as? OptionalType,
                let rightType = rightType as? OptionalType
            {
                return matchTypes(kind: kind,
                                  left: leftType.wrapped,
                                  right: rightType.wrapped,
                                  options: subOptions)
            }
            return .failure
        }
    }
    
    public func simplifyApplicableFunctionConstraint(left lfn: FunctionType,
                                                     right: Type,
                                                     options: MatchOptions) -> SolveResult
    {
        func ambiguous() -> SolveResult {
            if options.generateConstraintsWhenAmbiguous {
                let c = Constraint.applicableFunction(left: lfn, right: right)
                _addConstraintEntry(ConstraintEntry(c))
                return .solved
            }
            return .ambiguous
        }
        
        let right = simplify(type: right)
        
        if let _ = right as? TypeVariable {
            return ambiguous()
        }
        
        guard let rfn = right as? FunctionType else {
            return .failure
        }
        // lfn (Int) -> $T1
        // rfn  (Int) -> String
        
        var subOpts = options
        subOpts.generateConstraintsWhenAmbiguous = true
        
        let matchArg = matchTypes(kind: .bind, left: lfn.parameter, right: rfn.parameter, options: subOpts)
        let matchResult = matchTypes(kind: .bind, left: lfn.result, right: rfn.result, options: subOpts)
        if matchArg == .solved && matchResult == .solved {
            return matchTypes(kind: .bind,
                              left: rfn,
                              right: right,
                              options: subOpts)
        }
        
        // <Q08 hint="think about semantics of appfn congsts" />
        
        return .solved
    }
    
    /**
     現在活性化している制約を可能な限り簡約化する事を繰り返す。
     */
    public func simplify() -> Bool {
        while true {
            if isFailed {
                return false
            }
            
            guard let cs = (constraints.first { $0.isActive }) else {
                break
            }
            cs.isActive = false
            
            switch simplify(constraint: cs.constraint) {
            case .failure:
                _removeConstraintEntry(cs)
                fail(constraint: cs)
                
            case .ambiguous:
                break
                
            case .solved:
                _removeConstraintEntry(cs)
            }
        }
        
        return true
    }
}
