import SwiftcBasic
import SwiftcType

public final class ASTDumper {
    public typealias VisitResult = Void
    
    private let pr: Printer
    private let source: SourceFile
    private let node: ASTNode

    public init(printer: Printer,
                source: SourceFile,
                node: ASTNode)
    {
        self.pr = printer
        self.source = source
        self.node = node
    }
    
    public func preWalk(node: ASTNode) throws -> PreWalkResult<ASTNode> {
        pr.goToLineHead()
        printOpen(node)
        pr.push()
        return .continue(node)
    }
    
    public func postWalk(node: ASTNode) throws -> WalkResult<ASTNode> {
        pr.pop()
        printClose()
        return .continue(node)
    }
    
    public func printOpen(_ node: ASTNode) {
        let desc = node.descriptionParts.joined(separator: " ")
        pr.print("(" + desc)
    }
    
    public func printClose() {
        pr.print(")")
    }
}

extension ASTNode {
    public func dump() {
        let pr = Printer()
        let dumper = ASTDumper(printer: pr,
                               source: source,
                               node: self)
        try! walk(preWalk: dumper.preWalk,
                  postWalk: dumper.postWalk)
        pr.ln()
    }
}
