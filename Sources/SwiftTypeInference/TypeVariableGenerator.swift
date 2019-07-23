import Foundation

public struct TypeVariableGenerator {
    private var lastID: Int = 0
    
    public init() {}
    
    public mutating func generate() -> TypeVariable {        
        let tv = TypeVariable(id: lastID + 1)
        lastID = tv.id
        return tv
    }
}
