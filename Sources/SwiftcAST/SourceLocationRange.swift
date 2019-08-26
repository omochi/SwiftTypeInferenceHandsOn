public struct SourceLocationRange : CustomStringConvertible, Hashable {
    public var name: String?
    public var beginLine: Int
    public var beginColumn: Int
    public var endLine: Int
    public var endColumn: Int
    
    public init(name: String?,
                beginLine: Int,
                beginColumn: Int,
                endLine: Int,
                endColumn: Int)
    {
        self.name = name
        self.beginLine = beginLine
        self.beginColumn = beginColumn
        self.endLine = endLine
        self.endColumn = endColumn
    }
    
    public var description: String {
        var tokens: [String] = []
        if let name = name {
            tokens.append(name)
        }
        tokens.append("\(beginLine)")
        tokens.append("\(beginColumn)")
        
        let str1 = tokens.joined(separator: ":")
        
        tokens = []
        tokens.append("\(endLine)")
        tokens.append("\(endColumn - 1)")
        
        let str2 = tokens.joined(separator: ":")
        
        return "[\(str1) - \(str2)]"
    }
}
