class TypeFindWalker : TypeWalker {
    let pred: (Type) -> Bool
    
    init(pred: @escaping (Type) -> Bool) {
        self.pred = pred
    }
    
    override func preWalk(type: Type) -> TypeWalker.PreAction {
        if pred(type) {
            return .stop
        }
        return .continue
    }
}

extension Type {
    public func find(_ pred: (Type) -> Bool) -> Bool {
        withoutActuallyEscaping(pred) { (pred) in
            switch walk(TypeFindWalker(pred: pred)) {
            case .continue: return false
            case .stop: return true
            }
        }
    }
}
