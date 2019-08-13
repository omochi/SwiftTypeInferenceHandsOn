import SwiftSyntax

public protocol ASTScope {
    var source: SourceFile { get }
    var scopeRange: Range<AbsolutePosition> { get }
}
