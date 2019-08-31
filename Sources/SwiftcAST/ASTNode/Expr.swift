import SwiftcBasic
import SwiftcType

public protocol Expr : ASTNode {
    var type: Type? { get set }
}

public enum Exprs {
    public static func descriptionParts(_ expr: Expr) -> [String] {
        var parts: [String] = []
        
        parts.append("type=\"\(str(expr.type))\"")
        
        parts += ASTNodes.descriptionParts(expr)
        
        return parts
    }
}
