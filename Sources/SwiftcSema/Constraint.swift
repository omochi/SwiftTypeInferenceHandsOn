import SwiftcBasic
import SwiftcType

public enum Constraint : CustomStringConvertible, Hashable {
    public enum Kind : Hashable {
        case bind
        case applicableFunction
    }
    
    case bind(left: Type, right: Type)
    case applicableFunction(left: FunctionType, right: Type)
    
    public var kind: Kind {
        switch self {
        case .bind: return .bind
        case .applicableFunction: return .applicableFunction
        }
    }
    
    public var description: String {
        switch self {
        case .bind(left: let left, right: let right):
            return "\(left) <<bind>> \(right)"
        case .applicableFunction(left: let left, right: let right):
            return "\(left) <<applicable fn>> \(right)"
        }
    }
    
    public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
        switch lhs {
        case .bind(left: let al, right: let ar):
            guard case .bind(let bl, let br) = rhs else {
                return false
            }
            return al == bl && ar == br
        case .applicableFunction(left: let al, right: let ar):
            guard case .applicableFunction(let bl, let br) = rhs else {
                return false
            }
            return al == bl && ar == br
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
        }
    }
    
    private var _types: [Type] {
        switch self {
        case .bind(left: let l, right: let r): return [l, r]
        case .applicableFunction(left: let l, right: let r): return [l, r]
        }
    }
    
    public var typeVariables: Set<TypeVariable> {
        var ret = Set<TypeVariable>()
        for ty in _types {
            ret.formUnion(ty.typeVariables)
        }
        return ret
    }

}

