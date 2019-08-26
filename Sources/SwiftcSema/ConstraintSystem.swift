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
    
    public struct OverloadSelection {
        public var choice: OverloadChoice
        
        public init(choice: OverloadChoice) {
            self.choice = choice
        }
    }
    
    public struct Solution {
        public var bindings: TypeVariableBindings
        public var astTypes: [AnyASTNode: Type]
        public var overloadSelections: [AnyASTNode: OverloadSelection]
        
        public init(bindings: TypeVariableBindings,
                    astTypes: [AnyASTNode: Type],
                    overloadSelections: [AnyASTNode: OverloadSelection])
        {
            self.bindings = bindings
            self.astTypes = astTypes
            self.overloadSelections = overloadSelections
        }
        
        public func fixedType(for node: ASTNode) -> Type? {
            guard let ty = astTypes[node.eraseToAnyASTNode()] else {
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
    public private(set) var astTypes: [AnyASTNode: Type] = [:]
    public private(set) var overloadSelections: [AnyASTNode: OverloadSelection] = [:]
    
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
    
    public func hasFreeTypeVariables() -> Bool {
        return typeVariables.contains {
            $0.isFree(bindings: bindings) }
    }
    
    public func currentSolution() -> Solution {
        return Solution(bindings: bindings,
                        astTypes: astTypes,
                        overloadSelections: overloadSelections)
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
        if let type = astTypes[node.eraseToAnyASTNode()] {
            return type
        }
        
        if let ex = node as? ASTExprNode {
            return ex.type
        }
        
        if let ctx = node as? DeclContext {
            return ctx.interfaceType
        }
        
        return nil
    }
    
    public func setASTType(for node: ASTNode, _ type: Type) {
        let key = node.eraseToAnyASTNode()
        if let _ = astTypes[key] {
            preconditionFailure("already set")
        }
        astTypes[key] = type
    }
    
    public func addConstraint(kind: Constraint.Kind,
                              left: Type, right: Type)
    {
        func submit() -> SolveResult {
            var options = MatchOptions()
            options.generateConstraintsWhenAmbiguous = true
            switch kind {
            case .bind:
                return matchTypes(kind: kind,
                                  left: left, right: right,
                                  options: options)
            case .applicableFunction:
                return simplifyApplicableFunctionConstraint(left: left as! FunctionType,
                                                            right: right,
                                                            options: options)
            case .bindOverload,
                 .disjunction:
                preconditionFailure("invalid kind: \(kind)")
            }
        }
    
        switch submit() {
        case .solved:
            break
        case .failure:
            let fc = Constraint(kind: kind, left: left, right: right)
            fail(constraint: ConstraintEntry(fc))
            break
        case .ambiguous:
            fatalError("addConstraint forbids ambiguous")
        }
    }
    
    public func removeConstraint(_ constraint: ConstraintEntry) {
        constraints.removeAll { $0 == constraint }
    }
    
    public func addDisjunctionConstraint(_ constraints: [Constraint]) {
        _addAmbiguousConstraint(.disjunction(constraints: constraints))
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
    
    public func resolveOverload(boundType: Type,                                
                                choice: OverloadChoice,
                                location: ASTNode)
    {
        guard let declType = astType(for: choice.decl) else {
            fail(constraint: ConstraintEntry(.bindOverload(left: boundType,
                                                           choice: choice,
                                                           location: location)))
            return
        }
        
        addConstraint(kind: .bind, left: boundType, right: declType)
        overloadSelections[location.eraseToAnyASTNode()] = OverloadSelection(choice: choice)
    }
}
