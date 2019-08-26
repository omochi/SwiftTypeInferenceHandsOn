public struct AnyASTNode : Hashable {
    private let value: ASTNode
    
    public init(_ value: ASTNode) {
        self.value = value
    }
    
    public func cast<T>(to type: T.Type) -> T? {
        value as? T
    }
    
    public static func ==(a: AnyASTNode, b: AnyASTNode) -> Bool {
        ObjectIdentifier(a.value) == ObjectIdentifier(b.value)
    }
    
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(value).hash(into: &hasher)
    }
}

extension ASTNode {
    public func eraseToAnyASTNode() -> AnyASTNode {
        return AnyASTNode(self)
    }
}
