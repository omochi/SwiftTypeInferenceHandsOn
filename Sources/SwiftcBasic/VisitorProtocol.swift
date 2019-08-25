public protocol VisitorProtocol {
    associatedtype VisitTarget
    associatedtype VisitResult
    
    func visit(_ target: VisitTarget) throws -> VisitResult
}

