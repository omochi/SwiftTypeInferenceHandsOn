import Foundation

public final class TypeWalker : TypeVisitor {
    public enum PreAction {
        case `continue`
        case skipChildren
        case stop
    }
    
    public enum Action {
        case `continue`
        case stop
    }

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
  
    fileprivate func process(type: Type) -> Action {
        switch preWalk(type) {
        case .continue:
            break
        case .skipChildren:
            return .continue
        case .stop:
            return .stop
        }
        
        switch visit(type: type) {
        case .continue:
            break
        case .stop:
            return .stop
        }
        
        switch postWalk(type) {
        case .continue:
            return .continue
        case .stop:
            return .stop
        }
    }
    
    public func visitPrimitiveType(_ type: PrimitiveType) -> Action {
        .continue
    }
    
    public func visitFunctionType(_ type: FunctionType) -> Action {
        switch process(type: type.argument) {
        case .continue: break
        case .stop: return .stop
        }
        
        return process(type: type.result) 
    }
    
    public func visitTypeVariable(_ type: _TypeVariable) -> Action {
        .continue
    }
}

extension Type {
    public func walk(preWalk: (Type) -> TypeWalker.PreAction = { (_) in .continue },
                     postWalk: (Type) -> TypeWalker.Action = { (_) in .continue })
        -> TypeWalker.Action
    {
        withoutActuallyEscaping(preWalk) { (preWalk) in
            withoutActuallyEscaping(postWalk) { (postWalk) in
                let walker = TypeWalker(preWalk: preWalk,
                                        postWalk: postWalk)
                return walker.process(type: self)
            }
        }
    }
    
    /**
     型を巡回してpredを満たすものがあればtrueを返す。
     predは親が先に呼び出される。
     */
    public func find(_ pred: (Type) -> Bool) -> Bool {
        func preWalk(type: Type) -> TypeWalker.PreAction {
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
