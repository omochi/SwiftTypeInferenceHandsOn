import SwiftcBasic

public final class TypeWalker : VisitorWalkerBase, TypeVisitor {
    public typealias VisitTarget = Type
    public typealias VisitResult = Action
    
    public let preWalk: (Type) -> PreAction
    public let postWalk: (Type) -> Action
    
    public init(
        preWalk: @escaping (Type) -> PreAction,
        postWalk: @escaping (Type) -> Action
    ) {
        self.preWalk = preWalk
        self.postWalk = postWalk
    }
    
    public func visitPrimitiveType(_ type: PrimitiveType) -> Action {
        .continue
    }
    
    public func visitFunctionType(_ type: FunctionType) -> Action {
        switch process(type.parameter) {
        case .continue: break
        case .stop: return .stop
        }
        
        switch process(type.result) {
        case .continue: break
        case .stop: return .stop
        }
        
        return .continue
    }
    
    public func visitTypeVariable(_ type: _TypeVariable) -> Action {
        .continue
    }
}

extension Type {
    public func walk(preWalk: (Type) -> WalkerPreAction = { (_) in .continue },
                     postWalk: (Type) -> WalkerAction = { (_) in .continue })
        -> WalkerAction
    {
        withoutActuallyEscaping(preWalk) { (preWalk) in
            withoutActuallyEscaping(postWalk) { (postWalk) in
                let walker = TypeWalker(preWalk: preWalk,
                                        postWalk: postWalk)
                return walker.process(self)
            }
        }
    }
    
    /**
     型を巡回してpredを満たすものがあればtrueを返す。
     predは親が先に呼び出される。
     */
    public func find(_ pred: (Type) -> Bool) -> Bool {
        func preWalk(type: Type) -> WalkerPreAction {
            if pred(type) {
                return .stop
            }
            return .continue
        }

        switch walk(preWalk: preWalk) {
        case .continue: return false
        case .stop: return true
        }
    }
}
