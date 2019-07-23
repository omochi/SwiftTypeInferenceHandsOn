import Foundation

public struct Unificator : CustomStringConvertible {
    public private(set) var substitutions: Substitutions
    
    public init() {
        self.substitutions = Substitutions()
    }
    
    public mutating func unify(constraint: Constraint) throws {
        let constraint = substitutions.apply(to: constraint)
        
        let left = constraint.left
        let right = constraint.right
        
        if let leftVar = left.asVariable() {
            substitutions = substitutions.map(from: left, to: right)
            substitutions.items[leftVar] = right
            return
        }
        
        if let _ = right.asVariable() {
            try unify(constraint: constraint.reversed())
            return
        }
        
        if left == right {
            return
        }
        
        if let leftFunc = left.as(type: FunctionType.self),
            let rightFunc = right.as(type: FunctionType.self),
            leftFunc.arguments.count == rightFunc.arguments.count
        {
            for (leftArg, rightArg) in zip(leftFunc.arguments, rightFunc.arguments) {
                try unify(constraint: Constraint(left: leftArg, right: rightArg))
            }
            try unify(constraint: Constraint(left: leftFunc.result, right: rightFunc.result))
            return
        }
        
        throw MessageError("\(left) != \(right)")
    }
    
    public var description: String {
        var lines: [String] = []
        
        for (left, right) in substitutions.items {
            lines.append("\(left) => \(right)")
        }
        
        return lines.joined(separator: "\n")
    }
}
