import Foundation

public final class EntitySpace : CustomStringConvertible {
    public var functions: [Function] = []
    
    public var description: String {
        var lines: [String] = []
        
        lines.append("functions:")
        for x in functions {
            lines.append(x.description)
        }
        
        return lines.joined(separator: "\n")
    }
}
