import SwiftcBasic

public struct OptionalType : _EquatableType {
    public struct Eq : Hashable {
        public var wrapped: AnyType
        public init(_ x: OptionalType) {
            wrapped = x.wrapped.eraseToAnyType()
        }
    }
    
    public var wrapped: Type
    
    public init(_ wrapped: Type) {
        self.wrapped = wrapped
    }
    
    public func print(options: TypePrintOptions) -> String {
        let wr = wrapped.print(options: TypePrintOptions(isInOptional: true))
        return "\(wr)?"
    }
    
    public static func == (lhs: OptionalType, rhs: OptionalType) -> Bool {
        Eq(lhs) == Eq(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Self.self))
        hasher.combine(Eq(self))
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : TypeVisitor {
        try visitor.visit(self)
    }
}

extension Type {
    public func lookThroughAllOptionals() -> [OptionalType] {
        var ret: [OptionalType] = []
        var type: Type = self
        while let optTy = type as? OptionalType {
            ret.append(optTy)
            type = optTy.wrapped
        }
        return ret
    }
}
