import SwiftcBasic

public protocol TypeVisitor : VisitorProtocol where VisitTarget == Type {
    func visitPrimitiveType(_ type: PrimitiveType) -> VisitResult
    func visitFunctionType(_ type: FunctionType) -> VisitResult
    func visitTypeVariable(_ type: _TypeVariable) -> VisitResult
}

extension TypeVisitor {
    public func visit(_ type: Type) -> VisitResult {
        type.accept(visitor: self)
    }
}
