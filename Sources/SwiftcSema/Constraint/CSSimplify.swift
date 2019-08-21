import SwiftcBasic
import SwiftcType

extension ConstraintSystem {
    internal func simplifyApplicableFunctionConstraint(left lfn: FunctionType,
                                                       right: Type,
                                                       options: MatchOptions) -> SolveResult
    {
        let right = simplify(type: right)
        
        if let _ = right as? TypeVariable {
            unimplemented()
        }
        
        guard let rfn = right as? FunctionType else {
            return .failure
        }
        
        var subOpts = options
        subOpts.generateConstraintsWhenAmbiguous = true
        
        switch matchTypes(left: lfn.parameter,
                          right: rfn.parameter,
                          kind: .bind,
                          options: subOpts) {
        case .failure: return .failure
        case .ambiguous: preconditionFailure("never")
        case .solved: break
        }
        
        switch matchTypes(left: rfn.result,
                          right: lfn.result,
                          kind: .bind,
                          options: subOpts) {
        case .failure: return .failure
        case .ambiguous: preconditionFailure("never")
        case .solved: break
        }
        
        return .solved
    }
}
