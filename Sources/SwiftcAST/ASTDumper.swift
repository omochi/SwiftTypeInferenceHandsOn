import SwiftcBasic

public final class ASTDumper : ASTVisitor {
    public typealias VisitResult = Void
    
    private let pr: Printer
    private let source: SourceFile
    private let node: ASTNode
    private var stack: [ASTNode]

    public init(printer: Printer,
                source: SourceFile,
                node: ASTNode)
    {
        self.pr = printer
        self.source = source
        self.node = node
        self.stack = []
    }
    
    public func preWalk(node: ASTNode) throws -> PreWalkResult<ASTNode> {
        if !stack.isEmpty {
            pr.ln()
            pr.push()
        }
        stack.append(node)
        
        printOpen(node)
        
        try node.accept(visitor: self)
        
        return .continue(node)
    }
    
    public func postWalk(node: ASTNode) throws -> WalkResult<ASTNode> {
        printClose()
        
        stack.removeLast()
        
        pr.pop()
        if stack.isEmpty {
            pr.ln()
        }
        return .continue(node)
    }
    
    public func printOpen(_ node: ASTNode) {
        let name = "\(type(of: node))"
        pr.print("(\(name)")
    }
    
    public func printClose() {
        pr.print(")")
    }
    
    public func visitASTNode(_ node: ASTNode) {
        var range = node.sourceLocationRange(source: source)
        range.name = nil
        pr.print(" range=\(range)")
    }
    
    public func visitValueDecl(_ valueDecl: ValueDecl) {
        pr.print(" name=\(valueDecl.name)")
        
        visitASTNode(valueDecl)
    }
    
    public func visitExpr(_ expr: ASTExprNode) {
        let typeStr = expr.type?.description ?? "(nil)"
        pr.print(" type=\"\(typeStr)\"")
    
        visitASTNode(expr)
    }
    
    public func visitSourceFile(_ node: SourceFile) throws -> Void {
        if let name = node.fileName {
            pr.print(" " + name)
        }
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) throws -> Void {
        visitValueDecl(node)
    }
    
    public func visitVariableDecl(_ node: VariableDecl) throws -> Void {
        visitValueDecl(node)
    }
    
    public func visitCallExpr(_ node: CallExpr) throws -> Void {
        visitExpr(node)
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> Void {
        visitExpr(node)
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> Void {
        visitExpr(node)
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) throws -> Void {
        visitExpr(node)
    }
    
    public func visitOverloadedDeclRefExpr(_ node: OverloadedDeclRefExpr) throws -> Void {
        visitExpr(node)
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> Void {
        visitExpr(node)
    }
    
}

extension ASTNode {
    public func dump(source: SourceFile) {
        let dumper = ASTDumper(printer: Printer(),
                               source: source,
                               node: self)
        try! walk(preWalk: dumper.preWalk,
                  postWalk: dumper.postWalk)
    }
    
    public func printSingle(source: SourceFile, printer: Printer) {
        let dumper = ASTDumper(printer: printer,
                               source: source,
                               node: self)
        dumper.printOpen(self)
        dumper.printClose()
    }
}
