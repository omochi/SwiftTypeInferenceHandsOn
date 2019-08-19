import SwiftcBasic

public final class ASTWalker : VisitorWalkerBase, ASTVisitor {
    public let preWalk: (ASTNode) -> PreAction
    public let postWalk: (ASTNode) -> Action
    
    public init(preWalk: @escaping (ASTNode) -> PreAction,
                postWalk: @escaping (ASTNode) -> Action)
    {
        self.preWalk = preWalk
        self.postWalk = postWalk
    }
    
    public func visit(_ node: ASTNode) -> Action {
        return .continue
    }
    
    public func visitSourceFile(_ node: SourceFile) -> Action {
        for s in node.statements {
            switch process(s) {
            case .continue: break
            case .stop: return .stop
            }
        }
        return .continue
    }
    
    public func visitFunctionDecl(_ node: FunctionDecl) -> Action {
        .continue
    }
    
    public func visitVariableDecl(_ node: VariableDecl) -> Action {
        .continue
    }
    
    public func visitCallExpr(_ node: CallExpr) -> Action {
        switch process(node.callee) {
        case .continue: break
        case .stop: return .stop
        }
        
        switch process(node.argument) {
        case .continue: break
        case .stop: return .stop
        }
        
        return .continue
    }
    
    public func visitClosureExpr(_ node: ClosureExpr) -> Action {
        switch process(node.parameter) {
        case .continue: break
        case .stop: return .stop
        }
        
        for s in node.body {
            switch process(s) {
            case .continue: break
            case .stop: return .stop
            }
        }
        
        return .continue
    }
    
    public func visitUnresolvedDeclRefExpr(_ node: UnresolvedDeclRefExpr) -> Action {
        .continue
    }
    
    public func visitDeclRefExpr(_ node: DeclRefExpr) -> WalkerAction {
        .continue
    }
    
    public func visitIntegerLiteralExpr(_ node: IntegerLiteralExpr) -> Action {
        .continue
    }

}
