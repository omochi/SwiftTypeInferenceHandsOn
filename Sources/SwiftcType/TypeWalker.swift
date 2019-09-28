import SwiftcBasic

public final class TypeWalker : WalkerBase, TypeVisitor {

    public typealias VisitTarget = Type
    public typealias VisitResult = WalkResult<Type>
    
    public let _preWalk: (Type) throws -> PreWalkResult<Type>
    public let _postWalk: (Type) throws -> WalkResult<Type>
    
    public init(
        preWalk: @escaping (Type) throws -> PreWalkResult<Type>,
        postWalk: @escaping (Type) throws -> WalkResult<Type>
    ) {
        _preWalk = preWalk
        _postWalk = postWalk
    }
    
    public func preWalk(_ target: Type) throws -> PreWalkResult<Type> {
        try _preWalk(target)
    }
    
    public func postWalk(_ target: Type) throws -> WalkResult<Type> {
        try _postWalk(target)
    }
    
    public func visit(_ type: PrimitiveType) throws -> WalkResult<Type> {
        .continue(type)
    }
    
    public func visit(_ type: FunctionType) throws -> WalkResult<Type> {
        var type = type
        
        switch try process(type.parameter) {
        case .terminate: return .terminate
        case .continue(let x):
            type.parameter = x
        }

        switch try process(type.result) {
        case .terminate: return .terminate
        case .continue(let x):
            type.result = x
        }
        
        return .continue(type)
    }
    
    public func visit(_ type: OptionalType) throws -> WalkResult<Type> {
        var type = type
        
        switch try process(type.wrapped) {
        case .terminate: return .terminate
        case .continue(let x):
            type.wrapped = x
        }
        
        return .continue(type)
    }
    
    public func visit(_ type: _TypeVariable) throws -> WalkResult<Type> {
        .continue(type)
    }
    
    public func visit(_ type: TopAnyType) throws -> WalkResult<Type> {
        .continue(type)
    }
    
}

extension Type {
    public func walk(preWalk: (Type) throws -> PreWalkResult<Type> = { (t) in .continue(t) },
                     postWalk: (Type) throws -> WalkResult<Type> = { (t) in .continue(t) })
        throws -> WalkResult<Type>
    {
        try withoutActuallyEscaping(preWalk) { (preWalk) in
            try withoutActuallyEscaping(postWalk) { (postWalk) in
                let walker = TypeWalker(preWalk: preWalk,
                                        postWalk: postWalk)
                return try walker.process(self)
            }
        }
    }
    
    /**
     型を巡回してpredを満たすものがあればtrueを返す。
     predは親が先に呼び出される。
     */
    public func find(_ pred: (Type) -> Bool) -> Bool {
        func preWalk(type: Type) -> PreWalkResult<Type> {
            if pred(type) {
                return .terminate
            }
            return .continue(type)
        }
        
        switch try! walk(preWalk: preWalk) {
        case .continue: return false
        case .terminate: return true
        }
    }
}
