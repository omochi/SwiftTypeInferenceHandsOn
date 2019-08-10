import Foundation

open class TypeWalker : TypeVisitor {
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
    
    open func preWalk(type: Type) -> PreAction {
        .continue
    }
    
    open func postWalk(type: Type) -> Action {
        .continue
    }
    
    fileprivate func process(type: Type) -> Action {
        switch preWalk(type: type) {
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
        
        switch postWalk(type: type) {
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
    public func walk(_ walker: TypeWalker) -> TypeWalker.Action {
        walker.process(type: self)
    }
}
