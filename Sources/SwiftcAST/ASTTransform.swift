import SwiftcBasic

extension ASTNode {
    /**
     exprを巡回して書き換える。
     親が子より先に呼び出される。
     fが型を返すと子の巡回はされない。
     fがnilを返した場合は子を巡回する。
     */
    public func transform(context: DeclContext,
                          _ f: (ASTNode, DeclContext) throws -> ASTNode?
    ) throws -> ASTNode
    {
        try withoutActuallyEscaping(f) { (f) in
            func preWalk(node: ASTNode, context: DeclContext) throws -> PreWalkResult<ASTNode> {
                if let expr = try f(node, context) {
                    return .skipChildren(expr)
                }
                
                return .continue(node)
            }
            
           
            switch try walk(context: context,
                            preWalk: preWalk) {
            case .continue(let x):
                return x
            case .terminate: preconditionFailure()
            }
        }
    }
}
