import SwiftcBasic

public protocol TypeVisitor : VisitorProtocol where VisitTarget == Type {
    func visitPrimitiveType(_ type: PrimitiveType) throws -> VisitResult
    func visitFunctionType(_ type: FunctionType) throws -> VisitResult
    func visitOptionalType(_ type: OptionalType) throws -> VisitResult
    func visitTypeVariable(_ type: _TypeVariable) throws -> VisitResult
}

extension TypeVisitor {
    public func visit(_ type: Type) throws -> VisitResult {
        try type.accept(visitor: self)
    }
}
