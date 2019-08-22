public protocol IdentityEquatable : AnyObject, Hashable {
}

extension IdentityEquatable {
    public var identifier: ObjectIdentifier {
        ObjectIdentifier(self)
    }
    
    public func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.identifier == b.identifier
    }
}
