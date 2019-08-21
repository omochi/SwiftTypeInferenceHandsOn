extension ConstraintSystem {
    public func solve() throws -> Solution {
        normalize()
        return currentSolution()
    }
}
