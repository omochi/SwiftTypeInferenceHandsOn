public protocol VisitorProtocol {
    associatedtype VisitTarget
    associatedtype VisitResult
    
    func startVisiting(_ target: VisitTarget) throws -> VisitResult
}

