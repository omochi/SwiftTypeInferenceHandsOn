import SwiftcBasic

extension ConstraintSystem {
    public final class SolveWork {
        public let cts: ConstraintSystem
        private let pr: Printer
        public var solutions: [Solution] = []
        
        public init(constraintSystem: ConstraintSystem) {
            self.cts = constraintSystem
            self.pr = cts.printer
        }
        
        public func run() {
            pr.println("==== solve start ====")
            
            _ = ComponentStep(work: self).run()
            
            pr.goToLineHead()
            pr.println("==== solve end ======")
            pr.println("solutions: \(solutions.count)")
        }
    }
    
    public func solve() -> [Solution] {
        let work = SolveWork(constraintSystem: self)
        work.run()        
        return work.solutions
    }
}
