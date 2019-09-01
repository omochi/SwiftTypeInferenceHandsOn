import SwiftcBasic
import SwiftcType

public protocol Expr : ASTNode {
    var type: Type? { get set }
}

extension Expr {
    public func typeOrThrow() throws -> Type {
        guard let ty = type else {
            throw MessageError("untyped expr: \(self)")
        }        
        return ty
    }
}

public enum Exprs {
    public static func descriptionParts(_ expr: Expr) -> [String] {
        var parts: [String] = []
        
        parts.append("type=\"\(str(expr.type))\"")
        
        parts += ASTNodes.descriptionParts(expr)
        
        return parts
    }
}
