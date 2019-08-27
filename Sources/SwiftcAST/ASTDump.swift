import SwiftcBasic

public final class ASTDumper : ASTVisitor {
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
        let name = "\(type(of: node))"
        pr.print("(\(name)")
        try! node.accept(visitor: self)
    }
    
    public func printClose() {
        pr.print(")")
    }
    
    public func visitASTNode(_ node: ASTNode) {
        var range = node.sourceLocationRange
        range.name = nil
        pr.print(" range=\(range)")
    }
    
    public func visitDeclContext(_ con: DeclContext) {
        if let ty = con.interfaceType {
            pr.print(" type=\"\(ty)\"")
        }
    }
    
    public func visitDecl(_ decl: Decl) {
        visitDeclContext(decl)
        visitASTNode(decl)
    }
    
    public func visitValueDecl(_ valueDecl: ValueDecl) {
        pr.print(" name=\(valueDecl.name)")
        
        visitDecl(valueDecl)
    }
    
    public func visitExpr(_ expr: Expr) {
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
    public func dump() {
        let pr = Printer()
        let dumper = ASTDumper(printer: pr,
                               source: source,
                               node: self)
        try! walk(preWalk: dumper.preWalk,
                  postWalk: dumper.postWalk)
        pr.ln()
    }
    
    public func print(printer: Printer)
    {
        let dumper = ASTDumper(printer: printer,
                               source: source,
                               node: self)
        dumper.printOpen(self)
        dumper.printClose()
    }
    
    public var description: String {
        let pr = Printer()
        return pr.capture {
            print(printer: pr)
        }
    }
}
