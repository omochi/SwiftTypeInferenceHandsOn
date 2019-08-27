import SwiftcBasic
import SwiftcType
import SwiftcAST

extension ConstraintSystem {
    public struct StepState {
        public var bindings: TypeVariableBindings
        public var astTypes: [AnyASTNode: Type]
        public var overloadSelections: [AnyASTNode: OverloadSelection]
        public var typeConversionRelations: [TypeConversionRelation]
        public var failedConstraint: ConstraintEntry?
        public var constraints: [ConstraintEntry]
    }
    
    public func storeStepState() -> StepState {
        return StepState(bindings: bindings,
                         astTypes: astTypes,
                         overloadSelections: overloadSelections,
                         typeConversionRelations: typeConversionRelations,
                         failedConstraint: failedConstraint,
                         constraints: constraints)
    }
    
    public func loadStepState(_ s: StepState) {
        self.bindings = s.bindings
        self.astTypes = s.astTypes
        self.overloadSelections = s.overloadSelections
        self.typeConversionRelations = s.typeConversionRelations
        self.failedConstraint = s.failedConstraint
        self.constraints = s.constraints
    }
    
    public struct ComponentStep {
        public let work: SolveWork
        private let cts: ConstraintSystem
        private let pr: Printer
        public init(work: SolveWork) {
            self.work = work
            self.cts = work.cts
            self.pr = work.cts.printer
        }
        
        public func run() -> Bool {
            pr.goToLineHead()
            pr.println("(componentStep")
            pr.push()
            defer {
                pr.pop()
                pr.print(")")
            }
            
            guard _run() else {
                pr.goToLineHead()
                pr.print("no solution")
                return false
            }
           
            return true
        }
        
        private func _run() -> Bool {
            guard cts.simplify() else {
                return false
            }
            
            let disjunctionOrNone = cts.selectDisjunction()
            
            if let disjunction = disjunctionOrNone {
                return DisjunctionStep(work: work, disjunction: disjunction).run()
            }
            
            if cts.hasFreeTypeVariables() {
                return false
            }
            
            pr.goToLineHead()
            pr.print("found solution")
            let solution = cts.formSolution()
            work.solutions.append(solution)
            return true
        }
    }

    private func selectDisjunction() -> ConstraintEntry? {
        return constraints.first { $0.constraint.kind == .disjunction }
    }
    
    public struct DisjunctionStep {
        public let work: SolveWork
        private let cts: ConstraintSystem
        private let pr: Printer
        public let disjunction: ConstraintEntry
        public init(work: SolveWork,
                    disjunction: ConstraintEntry)
        {
            self.work = work
            self.cts = work.cts
            self.pr = work.cts.printer
            self.disjunction = disjunction
        }
        
        public func run() -> Bool {
            let choices: [Constraint]
            switch disjunction.constraint {
            case .disjunction(let dj): choices = dj.constraints
            default: preconditionFailure()
            }
            
            pr.goToLineHead()
            pr.println("(disjunctionStep")
            pr.push()
            cts._removeConstraintEntry(disjunction)
            defer {
                cts._addConstraintEntry(disjunction)
                pr.pop()
                pr.print(")")
            }
            
            var isAnySolved = false
            
            for choice in choices {
                let state = cts.storeStepState()
                defer {
                    cts.loadStepState(state)
                }
                if attempt(choice: choice) {
                    isAnySolved = true
                }
            }
            
            return isAnySolved
        }
        
        private func attempt(choice: Constraint) -> Bool {
            pr.goToLineHead()
            pr.println("attempt: \(choice)")
            _ = cts.simplify(constraint: choice)
            return ComponentStep(work: work).run()
        }
    }

}
