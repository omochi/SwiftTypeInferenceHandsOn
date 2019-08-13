import SwiftSyntax

public protocol ASTNode {
    var sourceRange: Range<AbsolutePosition>? { get }
}
