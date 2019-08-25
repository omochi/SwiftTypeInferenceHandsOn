import SwiftcBasic

extension ASTExprNode {
    /**
     exprを巡回して書き換える。
     親が子より先に呼び出される。
     fが型を返すと子の巡回はされない。
     fがnilを返した場合は子を巡回する。
     */
    public func transformExpr(context: ASTContextNode,
                              _ f: (ASTExprNode, ASTContextNode) throws -> ASTExprNode?
    ) throws -> ASTExprNode
    {
        try withoutActuallyEscaping(f) { (f) in
            func preWalk(node: ASTNode, context: ASTContextNode) throws -> PreWalkResult<ASTNode> {
                guard let nodeExpr = node as? ASTExprNode else {
                    return .continue(node)
                }
                
                if let expr = try f(nodeExpr, context) {
                    return .skipChildren(expr)
                }
                
                return .continue(node)
            }
            
           
            switch try walk(context: context,
                            preWalk: preWalk) {
            case .continue(let x):
                return x as! ASTExprNode
            case .terminate: preconditionFailure()
            }
        }
    }
}
