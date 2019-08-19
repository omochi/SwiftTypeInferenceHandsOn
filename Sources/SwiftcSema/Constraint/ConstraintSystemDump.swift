import SwiftcBasic

extension ConstraintSystem {
    public func dump() {
        let pr = Printer()
        pr.println("typeVariables")
        pr.nest {
            for tv in typeVariables {
                pr.println(tv.description)
                pr.nest {
                    if tv.isRepresentative(bindings: bindings) {
                        var eqs = tv.equivalentTypeVariables(bindings: bindings)
                        eqs.remove(tv)
                        if !eqs.isEmpty {
                            pr.print("eqs: ")
                            pr.println(eqs.sorted().map { $0.description })
                        }
                    } else {
                        pr.println("eq to \(tv.representative(bindings: bindings))")
                    }
                    
                    pr.print("fixed: ")
                    pr.println(tv.fixedType(bindings: bindings)?.description ?? "nil")
                }
            }
        }
        
        if let con = failedConstraint {
            pr.println("failedConstraint")
            pr.nest {
                dump(constraint: con, printer: pr)
            }
        }
    }
    
    public func dump(constraint: ConstraintEntry, printer pr: Printer) {
        if constraint.isActive {
            pr.print("* ")
        } else {
            pr.print("- ")
        }
        
        pr.println(constraint.constraint.description)
    }
}
