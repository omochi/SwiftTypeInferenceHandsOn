import SwiftcBasic
import SwiftcType

extension ConstraintSystem {
    public func simplify(constraint: Constraint) -> SolveResult {
        let options = MatchOptions()
        switch constraint {
        case .bind(left: let left, right: let right):
            return matchTypes(kind: .bind,
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
    
    public func simplifyApplicableFunctionConstraint(left lfn: FunctionType,
                                                     right: Type,
                                                     options: MatchOptions) -> SolveResult
    {
        func ambiguous() -> SolveResult {
            if options.generateConstraintsWhenAmbiguous {
                let cs = Constraint.applicableFunction(left: lfn, right: right)
                _addAmbiguousConstraint(cs)
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
        
        var subOpts = options
        subOpts.generateConstraintsWhenAmbiguous = true
        
        switch matchTypes(kind: .bind,
                          left: lfn.parameter, right: rfn.parameter,
                          options: subOpts) {
        case .failure: return .failure
        case .ambiguous: preconditionFailure("never")
        case .solved: break
        }
        
        switch matchTypes(kind: .bind,
                          left: rfn.result, right: lfn.result,
                          options: subOpts) {
        case .failure: return .failure
        case .ambiguous: preconditionFailure("never")
        case .solved: break
        }
        
        return .solved
    }
}
