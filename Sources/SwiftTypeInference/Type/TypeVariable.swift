public struct TypeVariable :
    _EquatableType, _LeafType,
    Hashable
{
    public var id: Int
    
    public init(id: Int) {
        self.id = id
    }
    
    public var description: String {
        return "$t\(id)"
    }
}
