extension ConstraintSystem {
    public func solve() throws -> Solution {
        normalize()
        return currentSolution()
    }
    
    public func simplify() -> Bool {
        while true {
            guard let cs = (constraints.first { $0.isActive }) else {
                break
            }
            cs.isActive = false
            
            switch simplify(constraint: cs.constraint) {
            case .failure:
                removeConstraint(cs)
                fail(constraint: cs)
                
            case .ambiguous:
                break
                
            case .solved:
                removeConstraint(cs)
            }
            
            if isFailed {
                return false
            }
        }
        
        return true
    }
}
