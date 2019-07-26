import Foundation

public final class EntitySpace : CustomStringConvertible {
    public var functions: [String: Function] = [:]
    
    public var description: String {
        var lines: [String] = []
        
        lines.append("functions:")
        for x in functions {
            lines.append(x.value.description)
        }
        
        return lines.joined(separator: "\n")
    }
}
