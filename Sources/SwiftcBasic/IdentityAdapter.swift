public struct IdentityAdapter<X: AnyObject> : Hashable {
    public var value: X
    
    public init(_ x: X) {
        self.value = x
    }
    
    public var identifier: ObjectIdentifier {
        ObjectIdentifier(value)
    }
    
    public func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
    
    public static func ==(a: IdentityAdapter<X>, b: IdentityAdapter<X>) -> Bool {
        a.identifier == b.identifier
    }
}

extension IdentityAdapter : CustomStringConvertible where X : CustomStringConvertible {
    public var description: String {
        value.description
    }
}
