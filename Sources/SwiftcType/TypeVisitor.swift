import SwiftcBasic

public protocol TypeVisitor : VisitorProtocol where VisitTarget == Type {
    func visit(_ type: PrimitiveType) throws -> VisitResult
    func visit(_ type: FunctionType) throws -> VisitResult
    func visit(_ type: OptionalType) throws -> VisitResult
    func visit(_ type: _TypeVariable) throws -> VisitResult
    func visit(_ type: TopAnyType) throws -> VisitResult
}

extension TypeVisitor {
    public func startVisiting(_ type: Type) throws -> VisitResult {
        try type.accept(visitor: self)
    }
}
