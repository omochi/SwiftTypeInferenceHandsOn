import SwiftcBasic

public final class ASTExprTransformer : VisitorTransformerBase, ASTVisitor {
    public typealias VisitTarget = ASTNode
    public typealias VisitResult = ASTNode
    
    public let _transform: (ASTExprNode, ASTContextNode?) -> ASTExprNode?
    public var context: ASTContextNode?
    
    public init(context: ASTContextNode?,
                transform: @escaping (ASTExprNode, ASTContextNode?) -> ASTExprNode?)
    {
        self.context = context
        self._transform = transform
    }
    
    public func transform(_ node: ASTNode) -> ASTNode? {
        if let expr = node as? ASTExprNode {
            return _transform(expr, context)
        }
        return nil
    }
    
    private func scope(context: ASTContextNode, f: () throws -> Void) rethrows {
        let old = self.context
        self.context = context
        defer {
            self.context = old
        }
        try f()
    }
    
    public func visitSourceFile(_ node: SourceFile) -> ASTNode {
        scope(context: node) {
            for index in 0..<node.statements.count {
                node.statements[index] = process(node.statements[index])
            }
        }
        return node
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) -> ASTNode {
        return node
    }
    
    public func visitVariableDecl(_ node: VariableDecl) -> ASTNode {
        node.initializer = node.initializer.map { process($0) as! ASTExprNode }
        return node
    }
    
    public func visitCallExpr(_ node: CallExpr) -> ASTNode {
        node.callee = process(node.callee)
        node.argument = process(node.argument)
        return node
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) -> ASTNode {
        scope(context: node) {
            for index in 0..<node.body.count {
                node.body[index] = process(node.body[index])
            }
        }
        return node
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) -> ASTNode {
        node
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) -> ASTNode {
        node
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) -> ASTNode {
        node
    }
}

extension ASTExprNode {
    public func transformExpr(context: ASTContextNode?,
                              _ f: (ASTExprNode, ASTContextNode?) -> ASTExprNode?
    ) -> ASTExprNode
    {
        withoutActuallyEscaping(f) { (f) in
            var transformer: ASTExprTransformer!
            
            defer {
                transformer = nil
            }
            
            transformer = ASTExprTransformer(context: context,
                                             transform: f)
            return transformer.process(self) as! ASTExprNode
        }
    }
}
