import SwiftSyntax

public struct SourcePosition : RawRepresentable, Hashable {
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init(position: AbsolutePosition) {
        self.init(rawValue: position.utf8Offset)
    }
    
    public func toLocation(name: String?, map: SourceLineMap) -> SourceLocation {
        map.location(of: self, name: name)
    }
}
