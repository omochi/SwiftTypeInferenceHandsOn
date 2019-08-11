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
        public var generateConstraintsWhenAmbiguous: Bool = false
        
        public init() {}
    }

    public private(set) var typeVariables: [TypeVariable] = []
    public private(set) var bindings: TypeVariableBindings = TypeVariableBindings()

    public private(set) var failedConstraint: Constraint?
    
    public init() {}
    
    deinit {
    }
    
    public func createTypeVariable() -> TypeVariable {
        let id = typeVariables.count + 1
        let tv = TypeVariable(id: id)
        bindings.items[tv] = .fixed(nil)
        typeVariables.append(tv)
        return tv
    }
    
    /**
     型に含まれる型変数を再帰的に置換した型を返す。
     具体型の割当がない場合は代表型変数に置換する。
     */
    public func simplify(type: Type) -> Type {
        type.simplify(bindings: bindings)
    }

    public func fixedOrRepresentative(for typeVariable: TypeVariable) -> Type {
        typeVariable.fixedOrRepresentative(bindings: bindings)
    }
    
    public func mergeEquivalence(type1: TypeVariable,
                                 type2: TypeVariable)
    {
        bindings.merge(type1: type1, type2: type2)
    }
    
    public func assignFixedType(variable: TypeVariable,
                                type: Type)
    {
        bindings.assign(variable: variable, type: type)
    }
    
    public func addConstraint(_ descriptor: Constraint.Descriptor) {
        func submit() -> SolveResult {
            var options = MatchOptions()
            options.generateConstraintsWhenAmbiguous = true
            switch descriptor {
            case .bind(left: let left, right: let right):
                return matchTypes(left: left,
                                  right: right,
                                  kind: descriptor.kind,
                                  options: options)
            }
        }
    
        switch submit() {
        case .solved:
            break
        case .failure:
            if failedConstraint == nil {
                failedConstraint = Constraint(descriptor: descriptor)
            }
            
            break
        case .ambiguous:
            fatalError("addConstraint forbids ambiguous")
        }
    }

    public func matchTypes(left: Type,
                           right: Type,
                           kind: Constraint.Kind,
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
            
            return matchTypeVariableAndFixedType(variable: variable,
                                                 type: type,
                                                 kind: kind)
        }
        
        return matchFixedTypes(type1: left, type2: right,
                               kind: kind, options: options)
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
        }
    }
    
    private func matchTypeVariableAndFixedType(variable: TypeVariable,
                                               type: Type,
                                               kind: Constraint.Kind) -> SolveResult
    {
        precondition(variable.isRepresentative(bindings: bindings))
        switch kind {
        case .bind:            
            if variable.occurs(in: type) {
                return .failure
            }
            
            assignFixedType(variable: variable, type: type)
            return .solved
        }
    }
    
    private func matchFixedTypes(type1: Type,
                                 type2: Type,
                                 kind: Constraint.Kind,
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
                
                return matchFunctionTypes(type1: type1, type2: type2,
                                          kind: kind, options: options)
            }
            
            unimplemented()
        }
    }
    
    private func matchFunctionTypes(type1: FunctionType,
                                    type2: FunctionType,
                                    kind: Constraint.Kind,
                                    options: MatchOptions) -> SolveResult
    {
        let arg1 = type1.argument
        let arg2 = type2.argument
        
        let ret1 = type1.result
        let ret2 = type2.result
        
        var isAmbiguous = false
        
        switch kind {
        case .bind:
            switch matchTypes(left: arg1, right: arg2,
                              kind: kind, options: options)
            {
            case .failure: return .failure
            case .ambiguous:
                isAmbiguous = true
                break
            case .solved: break
            }
            
            switch matchTypes(left: ret1, right: ret2,
                              kind: kind, options: options)
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
        }
    }
}
