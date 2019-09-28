import SwiftcBasic

public final class ASTWalker : WalkerBase, ASTVisitor {
    public typealias VisitTarget = ASTNode
    public typealias VisitResult = WalkResult<ASTNode>
    
    public let _preWalk: (ASTNode, DeclContext?) throws -> PreWalkResult<ASTNode>
    public let _postWalk: (ASTNode, DeclContext?) throws -> WalkResult<ASTNode>
    
    public var context: DeclContext?
    
    public init(context: DeclContext?,
                preWalk: @escaping (ASTNode, DeclContext?) throws -> PreWalkResult<ASTNode>,
                postWalk: @escaping (ASTNode, DeclContext?) throws -> WalkResult<ASTNode>)
    {
        self.context = context
        _preWalk = preWalk
        _postWalk = postWalk
    }
    
    public func preWalk(_ target: ASTNode) throws -> PreWalkResult<ASTNode> {
        try _preWalk(target, context)
    }
    
    public func postWalk(_ target: ASTNode) throws -> WalkResult<ASTNode> {
        try _postWalk(target, context)
    }
    
    private func scope<R>(context: DeclContext, f: () throws -> R) rethrows -> R {
        let old = self.context
        self.context = context
        defer {
            self.context = old
        }
        return try f()
    }

    public func visit(_ node: SourceFile) throws -> WalkResult<ASTNode> {
        try scope(context: node) {
            for i in 0..<node.statements.count {
                switch try process(node.statements[i]) {
                case .continue(let x):
                    node.statements[i] = x
                case .terminate:
                    return .terminate
                }
            }
            return .continue(node)
        }
    }
    
    public func visit(_ node: VariableDecl) throws -> WalkResult<ASTNode> {
        try scope(context: node) {
            if let ie = node.initializer {
                switch try process(ie) {
                case .continue(let x):
                    node.initializer = (x as! Expr)
                case .terminate:
                    return .terminate
                }
            }
            
            return .continue(node)
        }
    }
    
    public func visit(_ node: CallExpr) throws -> WalkResult<ASTNode> {
        switch try process(node.callee) {
        case .continue(let x):
            node.callee = x as! Expr
        case .terminate:
            return .terminate
        }
        
        switch try process(node.argument) {
        case .continue(let x):
            node.argument = x as! Expr
        case .terminate:
            return .terminate
        }
        
        return .continue(node)
    }
    
    public func visit(_ node: ClosureExpr) throws -> WalkResult<ASTNode> {
        try scope(context: node) {
            switch try process(node.parameter) {
            case .continue(let x):
                node.parameter = (x as! VariableDecl)
            case .terminate:
                return .terminate
            }
            
            for i in 0..<node.body.count {
                switch try process(node.body[i]) {
                case .continue(let x):
                    node.body[i] = x
                case .terminate:
                    return .terminate
                }
            }

            return .continue(node)
        }
    }
    
    public func visit(_ node: InjectIntoOptionalExpr) throws -> WalkResult<ASTNode> {
        switch try process(node.subExpr) {
        case .terminate: return .terminate
        case .continue(let x):
            node.subExpr = x as! Expr
        }
        return .continue(node)
    }
    
    public func visit(_ node: BindOptionalExpr) throws -> WalkResult<ASTNode> {
        switch try process(node.subExpr) {
        case .terminate: return .terminate
        case .continue(let x):
            node.subExpr = x as! Expr
        }
        return .continue(node)
    }
    
    public func visit(_ node: OptionalEvaluationExpr) throws -> WalkResult<ASTNode> {
        switch try process(node.subExpr) {
        case .terminate: return .terminate
        case .continue(let x):
            node.subExpr = x as! Expr
        }
        return .continue(node)
    }
    
    public func visit<T: ASTNode>(_ node: T) throws -> WalkResult<ASTNode> {
        return .continue(node)
    }
}

extension ASTNode {
    @discardableResult
    public func walk(context: DeclContext,
                     preWalk: (ASTNode, DeclContext) throws -> PreWalkResult<ASTNode> =
        { (n, _) in .continue(n) },
                     postWalk: (ASTNode, DeclContext) throws -> WalkResult<ASTNode> =
        { (n, _) in .continue(n) })
        throws -> WalkResult<ASTNode>
    {
        try withoutActuallyEscaping(preWalk) { (preWalk) in
            try withoutActuallyEscaping(postWalk) { (postWalk) in
                let walker = ASTWalker(context: context,
                                       preWalk: { (n, c) in try preWalk(n, c!) },
                                       postWalk: { (n, c) in try postWalk(n, c!) }
                )
                return try walker.process(self)
            }
        }
    }
    
    @discardableResult
    public func walk(
        preWalk: (ASTNode) throws -> PreWalkResult<ASTNode> =
        { (n) in .continue(n) },
        postWalk: (ASTNode) throws -> WalkResult<ASTNode> =
        { (n) in .continue(n) })
        throws -> WalkResult<ASTNode>
    {
        try withoutActuallyEscaping(preWalk) { (preWalk) in
            try withoutActuallyEscaping(postWalk) { (postWalk) in
                let walker = ASTWalker(context: nil,
                                       preWalk: { (n, _) in try preWalk(n) },
                                       postWalk: { (n, _) in try postWalk(n) }
                )
                return try walker.process(self)
            }
        }
    }
}
