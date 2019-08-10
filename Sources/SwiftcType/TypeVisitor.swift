import Foundation
import SwiftcBasic

public protocol TypeVisitor {
    associatedtype VisitResult
    
    func visit(type: Type) -> VisitResult
  
    func visitPrimitiveType(_ type: PrimitiveType) -> VisitResult
    func visitFunctionType(_ type: FunctionType) -> VisitResult
    func visitTypeVariable(_ type: _TypeVariable) -> VisitResult
}

extension TypeVisitor {
    public func visit(type: Type) -> VisitResult {
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
