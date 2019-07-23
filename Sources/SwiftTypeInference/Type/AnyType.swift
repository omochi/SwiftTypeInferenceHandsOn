private class AnyTypeBoxBase : CustomStringConvertible {
    public var description: String { unimplemented() }
    
    public func equals(other: AnyTypeBoxBase) -> Bool { unimplemented() }
    
    public var type: Any.Type { unimplemented() }
    
    public func `is`(type: Any.Type) -> Bool { self.type == type }
    
    public func `as`<X: Type>(type: X.Type) -> X? { unimplemented() }
    
    public func map(_ f: (AnyType) throws -> AnyType) rethrows -> AnyType { unimplemented() }
}

private final class AnyTypeBox<X: Type> : AnyTypeBoxBase {
    public let value: X
    
    public init(_ value: X) {
        self.value = value
    }
    
    public override var description: String { value.description }
    
    public override var type: Any.Type { X.self }
    
    public override func equals(other: AnyTypeBoxBase) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        
        return value == other.value
    }
    
    public override func `as`<X : Type>(type: X.Type) -> X? { value as? X }
    
    public override func map(_ f: (AnyType) throws -> AnyType) rethrows -> AnyType {
        try value.map(f)
    }
}

public struct AnyType : Type {
    private var box: AnyTypeBoxBase
    
    public init<X: Type>(_ base: X) {
        box = AnyTypeBox(base)
    }
    
    public var description: String { box.description }
    
    public static func ==(a: AnyType, b: AnyType) -> Bool { a.box.equals(other: b.box) }
    
    public var type: Any.Type { box.type }
    
    public func `is`(type: Any.Type) -> Bool { box.is(type: type) }
    
    public func `as`<X: Type>(type: X.Type) -> X? { box.as(type: type) }
    
    public func asVariable() -> TypeVariable? { `as`(type: TypeVariable.self) }
    
    public func map(_ f: (AnyType) throws -> AnyType) rethrows -> AnyType { try box.map(f) }
}

extension Type {
    public func asAnyType() -> AnyType {
        if let self = self as? AnyType {
            return self
        }
        return AnyType(self)
    }
}
