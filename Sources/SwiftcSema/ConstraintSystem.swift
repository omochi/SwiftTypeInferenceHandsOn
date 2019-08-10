import Foundation
import SwiftcType

public final class ConstraintSystem {
    public enum MatchResult {
        case success
        case failure
    }
    
    public private(set) var typeVariables: [TypeVariable] = []
    
    public init() {}
    
    deinit {
        for tv in typeVariables {
            tv.release()
        }
    }
    
    public func createTypeVariable() -> TypeVariable {
        let id = typeVariables.count + 1
        let tv = TypeVariable(id: id)
        typeVariables.append(tv)
        return tv
    }
    
    public func addConstraint(_ constraint: Constraint) {
        switch constraint {
        case .bind(left: let left, right: let right):
            matchTypes(left: left, right: right, kind: constraint.kind)
        }
    }
    
    
    public func fixed(for type: Type) -> Type? {
        if let type = type as? TypeVariable {
            return type.representative.fixedType
        }
        
        return type
    }
    
    public func fixedOrRepresentative(for type: Type) -> Type {
        if var type = type as? TypeVariable {
            type = type.representative
            if let fixed = type.fixedType {
                return fixed
            }
            return type
        }
        
        return type
    }
    
    public func mergeEquivalence(type1: TypeVariable,
                                 type2: TypeVariable)
    {
        precondition(type1.isRepresentative)
        precondition(type1.fixedType == nil)
        precondition(type2.isRepresentative)
        precondition(type2.fixedType == nil)
        precondition(type1 != type2)
        
        var type1 = type1
        var type2 = type2
        
        if type1 > type2 {
            swap(&type1, &type2)
        }
       
        type1.equivalentTypeVariables += type2.equivalentTypeVariables
        type2.equivalentTypeVariables.removeAll()
        type1.equivalentTypeVariables.sort()
        
        
    
    }
    

    public func matchTypes(left: Type,
                           right: Type,
                           kind: Constraint.Kind) -> MatchResult
    {
        let left = fixedOrRepresentative(for: left)
        let right = fixedOrRepresentative(for: right)
        
        let leftVar = left as? TypeVariable
        let rightVar = right as? TypeVariable
        
        switch (leftVar, rightVar) {
        case (.some(let left), .some(let right)):
            return _matchTypeVariables(left: left, right: right, kind: kind)
        case (.some(let left), .none):
            switch kind {
            case .bind:
                return _matchTypeVariableAndFixedType(typeVariable: left,
                                                      fixedType: right,
                                                      kind: kind)
            }
        case (.none, .some(let right)):
            switch kind {
            case .bind:
                return _matchTypeVariableAndFixedType(typeVariable: right,
                                                      fixedType: left,
                                                      kind: kind)
            }
        case (.none, .none):
            break
        }
        
        fatalError()
    }
    
    private func _matchTypeVariables(left: TypeVariable,
                                     right: TypeVariable,
                                     kind: Constraint.Kind) -> MatchResult
    {
        if left == right {
            return .success
        }
        
        switch kind {
        case .bind:
            mergeEquivalence(type1: left, type2: right)
            return .success
        }
    }
    
    private func _matchTypeVariableAndFixedType(typeVariable: TypeVariable,
                                                fixedType: Type,
                                                kind: Constraint.Kind) -> MatchResult
    {
        fatalError()
    }
}
