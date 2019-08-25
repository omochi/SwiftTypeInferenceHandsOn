public struct Identity<X: AnyObject> : Hashable {
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
    
    public static func ==(a: Identity<X>, b: Identity<X>) -> Bool {
        a.identifier == b.identifier
    }
}

extension Identity : CustomStringConvertible where X : CustomStringConvertible {
    public var description: String {
        value.description
    }
}
