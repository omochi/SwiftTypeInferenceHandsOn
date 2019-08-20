public protocol VisitorProtocol {
    associatedtype VisitTarget
    associatedtype VisitResult
    
    func visit(_ target: VisitTarget) -> VisitResult
}

public protocol FailableVisitorProtocol {
    associatedtype VisitTarget
    associatedtype VisitResult
    
    func visit(_ target: VisitTarget) throws -> VisitResult
}
