import SwiftcType

public struct TypeConversionRelation : CustomStringConvertible, Hashable {
    public struct Eq : Hashable {
        public var conversion: Conversion
        public var left: TypeEquatableAdapter
        public var right: TypeEquatableAdapter
        public init(_ x: TypeConversionRelation) {
            conversion = x.conversion
            left = x.left.wrapInEquatable()
            right = x.right.wrapInEquatable()
        }
    }
    
    public var conversion: Conversion
    public var left: Type
    public var right: Type

    public init(conversion: Conversion,
                left: Type,
                right: Type)
    {
        self.conversion = conversion
        self.left = left
        self.right = right
    }
    
    public var description: String {
        "\(conversion) \(left) -c> \(right)"
    }
    
    public static func == (lhs: TypeConversionRelation, rhs: TypeConversionRelation) -> Bool {
        Eq(lhs) == Eq(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        Eq(self).hash(into: &hasher)
    }
}
