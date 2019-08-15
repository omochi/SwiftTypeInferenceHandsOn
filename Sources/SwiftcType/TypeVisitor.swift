import SwiftcBasic

public protocol TypeVisitor : VisitorProtocol where VisitTarget == Type {
    func visitPrimitiveType(_ type: PrimitiveType) -> VisitResult
    func visitFunctionType(_ type: FunctionType) -> VisitResult
    func visitTypeVariable(_ type: _TypeVariable) -> VisitResult
}

extension TypeVisitor {
    public func visit(_ type: Type) -> VisitResult {
        switch type {
        case let t as PrimitiveType:
            return visitPrimitiveType(t)
        case let t as FunctionType:
            return visitFunctionType(t)
        case let t as _TypeVariable:
            return visitTypeVariable(t)
        default:
            unimplemented()
        }
    }
}
