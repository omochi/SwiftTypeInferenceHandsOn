public protocol VisitorTransformerBase : VisitorProtocol
    where VisitResult == VisitTarget
{
    var transform: (VisitTarget) -> VisitTarget? { get }
    
    func process(_ target: VisitTarget) -> VisitTarget
}

extension VisitorTransformerBase {
    public func process(_ target: VisitTarget) -> VisitTarget {
        if let target = transform(target) {
            return target
        }
        
        return visit(target)
    }
}
