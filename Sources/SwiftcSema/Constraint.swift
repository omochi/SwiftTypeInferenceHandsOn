import SwiftcBasic
import SwiftcType
import SwiftcAST

public enum Constraint : CustomStringConvertible, Hashable {
    public enum Kind : Hashable {
        case bind
        case applicableFunction
        case bindOverload
    }
    
    case bind(left: Type, right: Type)
    case applicableFunction(left: FunctionType, right: Type)
    case bindOverload(left: Type, choice: OverloadChoice, location: ASTNode)
    
    public init(kind: Kind, left: Type, right: Type) {
        switch kind {
        case .bind:
            self = .bind(left: left, right: right)
        case .applicableFunction:
            self = .applicableFunction(left: left as! FunctionType, right: right)
        case .bindOverload:
            preconditionFailure()
        }
    }
    
    public var kind: Kind {
        switch self {
        case .bind: return .bind
        case .applicableFunction: return .applicableFunction
        case .bindOverload: return .bindOverload
        }
    }
    
    public var description: String {
        switch self {
        case .bind(left: let left, right: let right):
            return "\(left) <<bind>> \(right)"
        case .applicableFunction(left: let left, right: let right):
            return "\(left) <<applicable fn>> \(right)"
        case .bindOverload(left: let left, choice: let choice, location: _):
            return "\(left) <<bind overload>> \(choice)"
        }
    }
    
    public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
        switch (lhs, rhs) {
        case (.bind(left: let al, right: let ar),
              .bind(left: let bl, right: let br)):
            return al == bl && ar == br
        case (.bind, _): return false
            
        case (.applicableFunction(left: let al, right: let ar),
              .applicableFunction(let bl, let br)):
            return al == bl && ar == br
        case (.applicableFunction, _): return false
            
        case (.bindOverload(left: let at, choice: let ac, location: let alo),
              .bindOverload(left: let bt, choice: let bc, location: let blo)):
            return at == bt && ac == bc &&
                alo.eraseToAnyASTNode() == blo.eraseToAnyASTNode()
        case (.bindOverload, _): return false
        }
    }
    
    public func hash(into h: inout Hasher) {
        kind.hash(into: &h)
        switch self {
        case .bind(left: let l, right: let r):
            l.hash(into: &h)
            r.hash(into: &h)
        case .applicableFunction(left: let l, right: let r):
            l.hash(into: &h)
            r.hash(into: &h)
        case .bindOverload(left: let t, choice: let c, location: let l):
            t.hash(into: &h)
            c.hash(into: &h)
            l.eraseToAnyASTNode().hash(into: &h)
        }
    }
    
    public var containingTypes: [Type] {
        switch self {
        case .bind(left: let l, right: let r): return [l, r]
        case .applicableFunction(left: let l, right: let r): return [l, r]
        case .bindOverload(left: let t, choice: let c, location: _): return [t] + c.containingTypes
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

