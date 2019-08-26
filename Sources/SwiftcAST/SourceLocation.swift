public struct SourceLocation : CustomStringConvertible, Hashable {
    public var name: String?
    public var line: Int
    public var column: Int
    
    public init(name: String?,
                line: Int,
                column: Int)
    {
        self.name = name
        self.line = line
        self.column = column
    }
    
    public var description: String {
        var tokens: [String] = []
        if let name = name {
            tokens.append(name)
        }
        tokens.append("\(line)")
        tokens.append("\(column)")
        return tokens.joined(separator: ":")
    }
}

