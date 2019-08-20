public protocol VisitorTransformerBase : VisitorProtocol
    where VisitResult == VisitTarget
{
    func process(_ target: VisitTarget) -> VisitTarget
    func transform(_ target: VisitTarget) -> VisitTarget?
}

extension VisitorTransformerBase {
    public func process(_ target: VisitTarget) -> VisitTarget {
        if let target = transform(target) {
            return target
        }
        
        return visit(target)
    }
}
