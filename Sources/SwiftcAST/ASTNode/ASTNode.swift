import SwiftcBasic

public protocol ASTNode : AnyObject, CustomStringConvertible {
    // break retain cycle
    func dispose()
    
    var source: SourceFile { get }
    var sourceRange: SourceRange { get }
    
    func accept<V: ASTVisitor>(visitor: V) throws -> V.VisitResult
    
    var descriptionParts: [String] { get }
    var descriptionPartsTail: [String] { get }
}

extension ASTNode {
    public func dispose() {}
    
    public var sourceLocationRange: SourceLocationRange {
        sourceRange.toLocation(name: source.fileName, map: source.sourceLineMap)
    }
    
    public var descriptionPartsHead: String {
        let ty = type(of: self)
        return "\(ty)"
    }
    
    public var descriptionParts: [String] {
        [descriptionPartsHead] + descriptionPartsTail
    }
    
    public var description: String {
        "(" + descriptionParts.joined(separator: " ") + ")"
    }

}

public enum ASTNodes {
    public static func descriptionParts(_ node: ASTNode) -> [String] {
        var range = node.sourceLocationRange
        range.name = nil
        return ["range=\(range)"]
    }
}
