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
            
            
        }
        
        return true
    }
}
