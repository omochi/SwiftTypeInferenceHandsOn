import SwiftcBasic

public final class ASTExprTransformer : FailableVisitorTransformerBase, ASTFailableVisitor {
    public typealias VisitTarget = ASTNode
    public typealias VisitResult = ASTNode

    public let _transform: (ASTExprNode, ASTContextNode?) throws -> ASTExprNode?
    public var context: ASTContextNode?
    
    public init(context: ASTContextNode?,
                transform: @escaping (ASTExprNode, ASTContextNode?) throws -> ASTExprNode?)
    {
        self.context = context
        self._transform = transform
    }
    
    public func transform(_ node: ASTNode) throws -> ASTNode? {
        if let expr = node as? ASTExprNode {
            return try _transform(expr, context)
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
    
    public func visitSourceFile(_ node: SourceFile) throws -> ASTNode {
        try scope(context: node) {
            for index in 0..<node.statements.count {
                node.statements[index] = try process(node.statements[index])
            }
        }
        return node
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) throws -> ASTNode {
        return node
    }
    
    public func visitVariableDecl(_ node: VariableDecl) throws -> ASTNode {
        node.initializer = try node.initializer
            .map { try process($0) as! ASTExprNode }
        return node
    }
    
    public func visitCallExpr(_ node: CallExpr) throws -> ASTNode {
        node.callee = try process(node.callee)
        node.argument = try process(node.argument)
        return node
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) throws -> ASTNode {
        try scope(context: node) {
            for index in 0..<node.body.count {
                node.body[index] = try process(node.body[index])
            }
        }
        return node
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) throws -> ASTNode {
        node
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) throws -> ASTNode {
        node
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) throws -> ASTNode {
        node
    }
}

extension ASTExprNode {
    public func transformExpr(context: ASTContextNode?,
                              _ f: (ASTExprNode, ASTContextNode?) -> ASTExprNode?
    ) -> ASTExprNode
    {
        func ef(node: ASTExprNode, context: ASTContextNode?) throws -> ASTExprNode? {
            f(node, context)
        }
        
        return try! transformExpr(context: context, ef)
    }
    
    public func transformExpr(context: ASTContextNode?,
                              _ f: (ASTExprNode, ASTContextNode?) throws -> ASTExprNode?
    ) throws -> ASTExprNode
    {
        try withoutActuallyEscaping(f) { (f) in
            var transformer: ASTExprTransformer!
            
            defer {
                transformer = nil
            }
            
            transformer = ASTExprTransformer(context: context,
                                             transform: f)
            return try transformer.process(self) as! ASTExprNode
        }
    }
}
