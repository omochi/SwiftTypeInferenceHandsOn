import Foundation

public struct Unificator : CustomStringConvertible {
    public private(set) var substitutions: [TypeVariable: AnyType] = [:]
    
    public init() {}
    
    public mutating func unify(constraint: Constraint) throws {
        let constraint = constraint.map { (t) in
            if let tv = t.asVariable(),
                let s = substitutions[tv]
            {
                return s
            }
            
            return t
        }
        
        let left = constraint.left
        let right = constraint.right
        
        if let leftVar = left.asVariable() {
            map(from: left, to: right)
            substitutions[leftVar] = right
            return
        }
        
        if let _ = right.asVariable() {
            try unify(constraint: constraint.reversed())
            return
        }
        
        if left.type == right.type {
            return
        }
        
        throw MessageError("\(left) != \(right)")
    }
    
    public mutating func map(_ f: (AnyType) -> AnyType) {
        substitutions = substitutions.mapValues(f)
    }
    
    public mutating func map(from: AnyType, to: AnyType) {
        map { (t) in
            if t == from {
                return to
            }
            return t
        }
    }
    
    public var description: String {
        var lines: [String] = []
        
        for (left, right) in substitutions {
            lines.append("\(left) => \(right)")
        }
        
        return lines.joined(separator: "\n")
    }
}
