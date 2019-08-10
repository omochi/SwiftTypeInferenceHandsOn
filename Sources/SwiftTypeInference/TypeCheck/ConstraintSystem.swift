import Foundation

public final class ConstraintSystem {
    public private(set) var typeVariables: [TypeVariable] = []
    
    deinit {
        for tv in typeVariables {
            tv.release()
        }
    }
    
    public func createTypeVariable() -> TypeVariable {
        let id = typeVariables.count + 1
        let tv = TypeVariable(constraintSystem: self,
                              id: id)
        typeVariables.append(tv)
        return tv
    }
    
    public func addConstraint(_ constraint: Constraint) {
        
    }
    
}
