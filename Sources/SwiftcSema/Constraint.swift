import SwiftcBasic
import SwiftcType
import SwiftcAST

public enum Constraint : CustomStringConvertible, Hashable {
    public enum Kind : Hashable {
        case bind
        case conversion
        case applicableFunction
        case bindOverload
        case disjunction
        
        public func toMatchKind() -> MatchKind? {
            switch self {
            case .bind: return .bind
            case .conversion: return .conversion
            case .applicableFunction,
                 .bindOverload,
                 .disjunction: return nil
            }
        }
    }
    
    public enum MatchKind {
        case bind
        case conversion
        
        public func asKind() -> Kind {
            switch self {
            case .bind: return .bind
            case .conversion: return .conversion
            }
        }
    }
    
    public struct Disjunction : Hashable {
        public var constraints: [Constraint]
        
        public init(constraints cs: [Constraint]) {
            var constraints: [Constraint] = []
            
            // flatten
            for c in cs {
                if case .disjunction(let disj) = c {
                    constraints.append(contentsOf: disj.constraints)
                } else {
                    constraints.append(c)
                }
            }
            
            if constraints.count >= 2 {
                let c0 = constraints[0]
                let areAllLeftsSame = constraints[1...].allSatisfy { c0.left == $0.left }
                precondition(areAllLeftsSame)
            }
            
            self.constraints = constraints
        }
    }
    
    case bind(left: Type, right: Type, conversion: Conversion? = nil)
    case conversion(left: Type, right: Type, conversion: Conversion? = nil)
    case applicableFunction(left: FunctionType, right: Type)
    case bindOverload(left: Type, choice: OverloadChoice, location: ASTNode)
    case disjunction(Disjunction)
    
    public init(kind: Kind, left: Type, right: Type) {
        switch kind {
        case .bind:
            self = .bind(left: left, right: right)
        case .conversion:
            self = .conversion(left: left, right: right)
        case .applicableFunction:
            self = .applicableFunction(left: left as! FunctionType, right: right)
        case .bindOverload,
             .disjunction:
            preconditionFailure("invalid kind: \(kind)")
        }
    }
    
    public init(kind: MatchKind, left: Type, right: Type, conversion: Conversion) {
        switch kind {
        case .bind:
            precondition(conversion == .deepEquality)
            self = .bind(left: left, right: right, conversion: conversion)
        case .conversion:
            self = .conversion(left: left, right: right, conversion: conversion)
        }
    }
    
    public static func disjunction(constraints: [Constraint]) -> Constraint {
        .disjunction(Disjunction(constraints: constraints))
    }

    public var kind: Kind {
        switch self {
        case .bind: return .bind
        case .conversion: return .conversion
        case .applicableFunction: return .applicableFunction
        case .bindOverload: return .bindOverload
        case .disjunction: return .disjunction
        }
    }
    
    public var description: String {
        func convStr(_ conv: Conversion?) -> String {
            if let conv = conv {
                return " \(conv)"
            }
            return ""
        }
        
        switch self {
        case .bind(left: let left, right: let right, let conv):
            return "\(left) <<bind>> \(right)\(convStr(conv))"
        case .conversion(left: let left, right: let right, let conv):
            return "\(left) <<conversion>> \(right)\(convStr(conv))"
        case .applicableFunction(left: let left, right: let right):
            return "\(left) <<applicable fn>> \(right)"
        case .bindOverload(left: let left, choice: let choice, location: _):
            return "\(left) <<bind overload>> choice=\(choice)"
        case .disjunction(let dj):
            return "disjunction => " +
                dj.constraints.map { "(\($0))" }.joined(separator: ", ")
        }
    }
    
    public var left: Type {
        switch self {
        case .bind(left: let left, right: _, conversion: _),
             .conversion(left: let left, right: _, conversion: _),
             .bindOverload(left: let left, choice: _, location: _):
            return left
        case .applicableFunction(left: let left, right: _):
            return left
        case .disjunction:
            preconditionFailure("invalid kind: \(self.kind)")
        }
    }
    
    public var right: Type {
        switch self {
        case .bind(left: _, right: let right, conversion: _),
             .conversion(left: _, right: let right, conversion: _),
             .applicableFunction(left: _, right: let right):
            return right
        case .bindOverload,
             .disjunction:
            preconditionFailure("invalid kind: \(self.kind)")
        }
    }
    
    public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
        switch (lhs, rhs) {
        case (.bind(left: let al, right: let ar, conversion: let ac),
              .bind(left: let bl, right: let br, conversion: let bc)):
            return al == bl && ar == br && ac == bc
        case (.bind, _): return false
            
        case (.conversion(left: let al, right: let ar, conversion: let ac),
              .conversion(left: let bl, right: let br, conversion: let bc)):
            return al == bl && ar == br && ac == bc
        case (.conversion, _): return false
            
        case (.applicableFunction(left: let al, right: let ar),
              .applicableFunction(let bl, let br)):
            return al == bl && ar == br
        case (.applicableFunction, _): return false
            
        case (.bindOverload(left: let at, choice: let ac, location: let alo),
              .bindOverload(left: let bt, choice: let bc, location: let blo)):
            return at == bt && ac == bc &&
                alo.eraseToAnyASTNode() == blo.eraseToAnyASTNode()
        case (.bindOverload, _): return false
            
        case (.disjunction(let adj), .disjunction(let bdj)):
            return adj == bdj
        case (.disjunction, _): return false
        }
    }
    
    public func hash(into h: inout Hasher) {
        kind.hash(into: &h)
        switch self {
        case .bind(left: let l, right: let r, conversion: let cv):
            l.hash(into: &h)
            r.hash(into: &h)
            cv.hash(into: &h)
        case .conversion(left: let l, right: let r, conversion: let cv):
            l.hash(into: &h)
            r.hash(into: &h)
            cv.hash(into: &h)
        case .applicableFunction(left: let l, right: let r):
            l.hash(into: &h)
            r.hash(into: &h)
        case .bindOverload(left: let t, choice: let c, location: let l):
            t.hash(into: &h)
            c.hash(into: &h)
            l.eraseToAnyASTNode().hash(into: &h)
        case .disjunction(let dj):
            dj.hash(into: &h)
        }
    }
    
    public var containingTypes: [Type] {
        switch self {
        case .bind(left: let l, right: let r, conversion: _): return [l, r]
        case .conversion(left: let l, right: let r, conversion: _): return [l, r]
        case .applicableFunction(left: let l, right: let r): return [l, r]
        case .bindOverload(left: let t, choice: let c, location: _): return [t] + c.containingTypes
        case .disjunction(let dj): return dj.constraints.flatMap { $0.containingTypes }
        }
    }
    
    public var typeVariables: Set<TypeVariable> {
        var ret = Set<TypeVariable>()
        for ty in containingTypes {
            ret.formUnion(ty.typeVariables)
        }
        return ret
    }

}

