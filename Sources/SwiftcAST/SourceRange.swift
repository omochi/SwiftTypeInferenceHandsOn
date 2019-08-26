import SwiftSyntax

public struct SourceRange : Hashable {
    public var begin: SourcePosition
    public var end: SourcePosition
    
    public init(begin: SourcePosition,
                end: SourcePosition)
    {
        self.begin = begin
        self.end = end
    }
    
    public init(begin: AbsolutePosition,
                end: AbsolutePosition)
    {
        self.init(begin: SourcePosition(position: begin),
                  end: SourcePosition(position: end))
    }
    
    public init(syntax: Syntax) {
        self.init(begin: syntax.positionAfterSkippingLeadingTrivia,
                  end: syntax.endPositionBeforeTrailingTrivia)
    }

    public func toLocation(name: String?, map: SourceLineMap) -> SourceLocationRange {
        map.location(of: self, name: name)
    }
}
