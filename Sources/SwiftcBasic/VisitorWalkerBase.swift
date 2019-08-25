public enum PreWalkResult<T> {
    case `continue`(T)
    case skipChildren(T)
    case terminate
}

public enum WalkResult<T> {
    case `continue`(T)
    case terminate
}

public protocol WalkerBase : VisitorProtocol
    where VisitResult == WalkResult<VisitTarget>
{
    func preWalk(_ target: VisitTarget) throws -> PreWalkResult<VisitTarget>
    func postWalk(_ target: VisitTarget) throws -> WalkResult<VisitTarget>
    func process(_ target: VisitTarget) throws -> WalkResult<VisitTarget>
}

extension WalkerBase {
    public func process(_ target: VisitTarget) throws -> WalkResult<VisitTarget> {
        var target = target
        
        let pre = try preWalk(target)
        switch pre {
        case .continue(let x):
            target = x
        case .skipChildren(let x):
            return .continue(x)
        case .terminate:
            return .terminate
        }
        
        switch try visit(target) {
        case .continue(let x):
            target = x
        case .terminate:
            return .terminate
        }
        
        switch try postWalk(target) {
        case .continue(let x):
            target = x
        case .terminate:
            return .terminate
        }
        
        return .continue(target)
    }
}
