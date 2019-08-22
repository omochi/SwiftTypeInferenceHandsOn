public struct CacheTable<Key: Hashable, Result> {
    private let generateResult: (Key) -> Result
    
    private var table: [Key: Result] = [:]
    
    public init(generateResult: @escaping (Key) -> Result)
    {
        self.generateResult = generateResult
    }
    
    public mutating func get(_ key: Key) -> Result {
        if let result = table[key] {
            return result
        }
        let result = generateResult(key)
        table[key] = result
        return result
    }
}
