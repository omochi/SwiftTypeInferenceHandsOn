public final class TypeVariable :
    _EquatableType, _LeafType,
    Comparable,
    Hashable
{
    public struct Representation {
        public var equivalentEntries: [TypeVariable] = []
        public var fixedType: Type? = nil
    }
    
    public enum Equivalence {
        case representation(Representation)
        case equivalent(TypeVariable)
    }
    
    public unowned let constraintSystem: ConstraintSystem
    public let id: Int
    public var equivalence: Equivalence { _equivalence! }
    private var _equivalence: Equivalence?
    
    internal init(
        constraintSystem: ConstraintSystem,
        id: Int)
    {
        self.constraintSystem = constraintSystem
        self.id = id
        
        let rep = Representation()
        self._equivalence = .representation(rep)
    }
    
    // explicit retain cycle destruction
    public func release() {
        _equivalence = nil
    }
    
    public var description: String {
        return "$T\(id)"
    }
    
    public static func ==(a: TypeVariable, b: TypeVariable) -> Bool {
        return a.id == b.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func <(a: TypeVariable, b: TypeVariable) -> Bool {
        return a.id < b.id
    }
    
    public var representation: Representation {
        switch equivalence {
        case .representation(let rep): return rep
        case .equivalent(let tv): return tv.representation
        }
    }
    
    public var fixedType: Type? {
        representation.fixedType
    }
}
