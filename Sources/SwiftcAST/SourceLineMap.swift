import Foundation

public struct SourceLineMap {
    public var offsets: [Int]
    
    public init(offsets: [Int]) {
        self.offsets = offsets
    }
    
    public init(source: String) {
        var data = source.data(using: .utf8)!
        data.append(0)
        self.init(nullTerminatedData: data)
    }
    
    public init(nullTerminatedData data: Data) {
        var offsets: [Int] = []
        var index = 0
        offsets.append(index)
        loop: while true {
            let c1 = data[index]
            switch c1 {
            case 0x0A:
                index += 1
                offsets.append(index)
            case 0x0D:
                let c2 = data[index + 1]
                switch c2 {
                case 0x0A:
                    index += 2
                    offsets.append(index)
                default:
                    index += 1
                    offsets.append(index)
                }
            case 0x00:
                break loop
            default:
                index += 1
            }
        }
        self.init(offsets: offsets)
    }
    
    public func location(of position: SourcePosition, name: String?) -> SourceLocation {
        let line = offsets.binarySearch { $0 <= position.rawValue } - 1
        let column = position.rawValue - offsets[line]
        return SourceLocation(name: name,
                              line: line + 1,
                              column: column + 1)
    }
    
    public func location(of range: SourceRange, name: String?) -> SourceLocationRange {
        let begin = location(of: range.begin, name: nil)
        let end = location(of: range.end, name: nil)
        return SourceLocationRange(name: name,
                                   beginLine: begin.line,
                                   beginColumn: begin.column,
                                   endLine: end.line,
                                   endColumn: end.column)
    }
    
    
}
