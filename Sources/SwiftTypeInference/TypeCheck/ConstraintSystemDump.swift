extension ConstraintSystem {
    public func dump() {
        var pr = Printer()
        pr.println("TypeVariables")
        
        for tv in typeVariables {
            pr.println(tv.description)
            pr.nest { (pr) in
                switch tv.equivalence {
                case .representation(let rep):
                    pr.print("equivs:")
                    pr.println(rep.equivalentEntries.map { $0.description })
                    
                    pr.println("fixed: " + (tv.fixedType?.description ?? "nil"))
                case .equivalent(let tv):
                    pr.println("equivalent to \(tv)")
                    pr.println("fixed: " + (tv.fixedType?.description ?? "nil"))
                }
            }
            pr.ln()
        }
    }
}
