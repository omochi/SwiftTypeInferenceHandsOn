import SwiftcBasic

extension Type {
    /**
     型を巡回して書き換える。
     親が子より先に呼び出される。
     fが型を返すと子の巡回はされない。
     fがnilを返した場合は子を巡回する。
    */
    public func transform(_ f: (Type) -> Type?) -> Type {
        withoutActuallyEscaping(f) { (f) in
            func preWalk(type: Type) -> PreWalkResult<Type> {
                if let type = f(type) {
                    return .skipChildren(type)
                }
                return .continue(type)
            }
            
            switch try! walk(preWalk: preWalk) {
            case .continue(let t): return t
            case .terminate: preconditionFailure()
            }
        }
    }
}
