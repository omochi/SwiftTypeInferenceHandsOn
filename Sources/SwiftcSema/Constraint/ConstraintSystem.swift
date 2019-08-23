import Foundation
import SwiftcBasic
import SwiftcType
import SwiftcAST

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
    
    public struct Solution {
        public var bindings: TypeVariableBindings
        public var astTypes: [ObjectIdentifier: Type]
        
        public init(bindings: TypeVariableBindings,
                    astTypes: [ObjectIdentifier: Type])
        {
            self.bindings = bindings
            self.astTypes = astTypes
        }
        
        public func fixedType(for node: ASTNode) -> Type? {
            guard let ty = astTypes[ObjectIdentifier(node)] else {
                return nil
            }
            if let tv = ty as? TypeVariable {
                return tv.fixedType(bindings: bindings)
            } else {
                return ty
            }
        }
    }

    public private(set) var typeVariables: [TypeVariable] = []
    public private(set) var bindings: TypeVariableBindings = TypeVariableBindings()
    public private(set) var astTypes: [ObjectIdentifier: Type] = [:]
    
    public private(set) var failedConstraint: ConstraintEntry?
    
    public private(set) var constraints: [ConstraintEntry] = []
    
    public init() {}
    
    deinit {
    }
    
    public func createTypeVariable() -> TypeVariable {
        let id = typeVariables.count + 1
        let tv = TypeVariable(id: id)
        bindings.setBinding(for: tv, .fixed(nil))
        typeVariables.append(tv)
        return tv
    }
    
    public func createTypeVariable(for node: ASTNode) -> TypeVariable {
        let tv = createTypeVariable()
        setASTType(for: node, tv)
        return tv
    }
    
    public func normalize() {
        for (node, type) in astTypes {
            astTypes[node] = simplify(type: type)
        }
    }
    
    public func doAllTypeVariablesHaveFixedType() -> Bool {
        return bindings.doAllTypeVariablesHaveFixedType()
    }
    
    public func currentSolution() -> Solution {
        return Solution(bindings: bindings,
                        astTypes: astTypes)
    }
    
    public func _addAmbiguousConstraint(_ constraint: Constraint) {
        let entry = ConstraintEntry(constraint)
        constraints.append(entry)
    }
    
    /**
     型に含まれる型変数を再帰的に置換した型を返す。
     固定型の割当がない場合は代表型変数に置換する。
     */
    public func simplify(type: Type) -> Type {
        type.simplify(bindings: bindings)
    }

    public func fixedOrRepresentative(for typeVariable: TypeVariable) -> Type {
        typeVariable.fixedOrRepresentative(bindings: bindings)
    }
    
    public func mergeEquivalence(type1: TypeVariable,
                                 type2: TypeVariable,
                                 activate: Bool = true)
    {
        bindings.merge(type1: type1, type2: type2)
        
        if activate {
            activateConstraints(involving: type1)
        }
    }
    
    public func assignFixedType(variable: TypeVariable,
                                type: Type,
                                activate: Bool = true)
    {
        bindings.assign(variable: variable, type: type)
        
        if activate {
            activateConstraints(involving: variable)
        }
    }
    
    public func astType(for node: ASTNode) -> Type? {
        if let type = astTypes[ObjectIdentifier(node)] {
            return type
        }
        
        if let ex = node as? ASTExprNode {
            return ex.type
        }
        
        if let ctx = node as? ASTContextNode {
            return ctx.interfaceType
        }
        
        return nil
    }
    
    public func setASTType(for node: ASTNode, _ type: Type) {
        astTypes[ObjectIdentifier(node)] = type
    }
    
    public func addConstraint(_ constraint: Constraint) {
        func submit() -> SolveResult {
            var options = MatchOptions()
            options.generateConstraintsWhenAmbiguous = true
            switch constraint {
            case .bind(left: let left, right: let right):
                return matchTypes(left: left, right: right,
                                  kind: constraint.kind, options: options)
            case .applicableFunction(left: let left, right: let right):
                return simplifyApplicableFunctionConstraint(left: left,
                                                            right: right,
                                                            options: options)
            }
        }
    
        switch submit() {
        case .solved:
            break
        case .failure:
            fail(constraint: ConstraintEntry(constraint))
            break
        case .ambiguous:
            fatalError("addConstraint forbids ambiguous")
        }
    }
    
    public func removeConstraint(_ constraint: ConstraintEntry) {
        constraints.removeAll { $0 == constraint }
    }
    
    public var isFailed: Bool {
        failedConstraint != nil
    }
    
    public func fail(constraint: ConstraintEntry) {
        if failedConstraint == nil {
            failedConstraint = constraint
        }
    }
    
    public func activateConstraints(involving typeVariable: TypeVariable) {
        let cs = gatherConstraints(involving: typeVariable)
        for c in cs {
            c.isActive = true
        }
    }

    public func gatherConstraints(involving typeVariable: TypeVariable) -> [ConstraintEntry] {
        ConstraintSystem.getherConstraints(involving: typeVariable,
                                           constraints: constraints,
                                           bindings: bindings)
    }
    
    public static func getherConstraints(involving typeVariable: TypeVariable,
                                         constraints: [ConstraintEntry],
                                         bindings: TypeVariableBindings) -> [ConstraintEntry]
    {
        var result = Set<ConstraintEntry>()
        
        // cache
        var csVarTable = CacheTable { (cs: ConstraintEntry) in
            cs.constraint.typeVariables
        }
        
        func getConstraints(contains tv: TypeVariable) -> [ConstraintEntry] {
            constraints.filter {
                csVarTable.get($0).contains(tv)
            }
        }
        
        var visitedAdjacents = Set<TypeVariable>()
        
        func gatherForAdjacents(_ typeVariable: TypeVariable) {
            for tv in typeVariable.equivalentTypeVariables(bindings: bindings) {
                let (inserted, _) = visitedAdjacents.insert(tv)
                guard inserted else { continue }
                for c in getConstraints(contains: tv) {
                    result.insert(c)
                }
            }
        }
        
        for tv in typeVariable.equivalentTypeVariables(bindings: bindings) {
            visitedAdjacents.insert(tv)
            for c in getConstraints(contains: tv) {
                result.insert(c)
            }
        }
        
        if let ft = typeVariable.fixedType(bindings: bindings) {
            for adj in ft.typeVariables {
                gatherForAdjacents(adj)
            }
        }
        
        return result.map { $0 }
    }
}
