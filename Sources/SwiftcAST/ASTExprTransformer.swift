import SwiftcBasic

public final class ASTExprTransformer : VisitorTransformerBase, ASTVisitor {
    public typealias VisitTarget = ASTNode
    public typealias VisitResult = ASTNode
    
    public let transform: (ASTNode) -> ASTNode?
    public var context: ASTContextNode?
    
    public init(context: ASTContextNode?,
                transform: @escaping (ASTNode) -> ASTNode?)
    {
        self.context = context
        self.transform = transform
    }
    
    private func scope(context: ASTContextNode, f: () -> Void) {
        let old = self.context
        self.context = context
        f()
        self.context = old
    }
    
    public func visitSourceFile(_ node: SourceFile) -> ASTNode {
        scope(context: node) {
            let codes = node.topLevelCodes
            for code in codes {
                node.replaceTopLevelCode(old: code,
                                         new: process(code))
            }
        }
        return node
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) -> ASTNode {
        return node
    }
    
    public func visitVariableDecl(_ node: VariableDecl) -> ASTNode {
        if let ie = node.initializer {
            let newIE = process(ie)
            if newIE !== ie {
                node.initializer = newIE
            }
        }
        return node
    }
    
    public func visitCallExpr(_ node: CallExpr) -> ASTNode {
        node.callee = process(node.callee)
        node.argument = process(node.argument)
        return node
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) -> ASTNode {
        scope(context: node) {
            for st in node.body {
                node.replaceBody(old: st, new: process(st))
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

extension ASTNode {
    public func transformExpr(context: ASTContextNode?,
                              _ f: (ASTNode, ASTContextNode?) -> ASTNode?
    ) -> ASTNode
    {
        withoutActuallyEscaping(f) { (f) in
            var transformer: ASTExprTransformer!
            
            defer {
                transformer = nil
            }
            
            func tr(_ node: ASTNode) -> ASTNode? {
                return f(node, transformer.context)
            }
            
            transformer = ASTExprTransformer(context: context,
                                             transform: tr)
            return transformer.process(self)
        }
    }
}
