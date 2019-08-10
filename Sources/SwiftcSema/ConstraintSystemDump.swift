import SwiftcBasic

extension ConstraintSystem {
    public func dump() {
        var pr = Printer()
        pr.println("TypeVariables")
        
        for tv in typeVariables {
            pr.println(tv.description)
            pr.nest { (pr) in
                if tv.isRepresentative {
                    pr.print("equivs:")
                    pr.println(tv.equivalentTypeVariables.map { $0.description })
                    
                    pr.println("fixed: " + (fixed(for: tv)?.description ?? "nil"))
                } else {
                    pr.println("equivalent to \(tv.representative)")
                    pr.println("fixed: " + (fixed(for: tv)?.description ?? "nil"))
                }
            }
            pr.ln()
        }
    }
}
