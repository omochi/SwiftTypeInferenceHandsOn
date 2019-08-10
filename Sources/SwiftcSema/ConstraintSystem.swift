import Foundation
import SwiftcBasic
import SwiftcType

public final class ConstraintSystem {
    public enum SolveResult {
        case solved
        case failure
        case ambiguous
    }
    
    public struct MatchOptions {
        public var generateConstraintsForUnsolvable: Bool = false
        
        public init() {}
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
        switch _addConstraint(constraint) {
        case .solved:
            break
        case .failure:
            break
        case .ambiguous:
            fatalError("addConstraint forbids ambiguous")
        }
    }
    
    private func _addConstraint(_ constraint: Constraint) -> SolveResult {
        var options = MatchOptions()
        options.generateConstraintsForUnsolvable = true
        switch constraint {
        case .bind(left: let left, right: let right):
            return matchTypes(left: left,
                              right: right,
                              kind: constraint.kind,
                              options: options)
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
        
        let news = [type2] + type2.equivalentTypeVariables
        type1.equivalentTypeVariables += news
        type1.equivalentTypeVariables.sort()
        
        for t in news {
            t.representative = type1
            t.equivalentTypeVariables.removeAll()
        }
    }

    public func matchTypes(left: Type,
                           right: Type,
                           kind: Constraint.Kind,
                           options: MatchOptions) -> SolveResult
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
                                     kind: Constraint.Kind) -> SolveResult
    {
        precondition(left.isRepresentative)
        precondition(right.isRepresentative)
        
        if left == right {
            return .solved
        }
        
        switch kind {
        case .bind:
            mergeEquivalence(type1: left, type2: right)
            return .solved
        }
    }
    
    private func _matchTypeVariableAndFixedType(typeVariable: TypeVariable,
                                                fixedType: Type,
                                                kind: Constraint.Kind) -> SolveResult
    {
        precondition(typeVariable.isRepresentative)
        
        switch kind {
        case .bind:
            if typeVariable.occurs(in: fixedType)
        }
    }
}
