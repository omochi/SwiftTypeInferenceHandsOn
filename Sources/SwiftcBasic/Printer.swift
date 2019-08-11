import Foundation

public final class Printer {
    public var depth: Int
    public var needsIndent: Bool
    
    public init(depth: Int = 0) {
        self.depth = depth
        self.needsIndent = true
    }
    
    public func push() {
        depth += 1
    }
    
    public func pop() {
        depth -= 1
    }
    
    public func nest(_ f: () throws -> Void) rethrows {
        push()
        defer { pop() }
        try f()
    }
    
    public func print(_ message: String, newLine: Bool = false) {
        if (needsIndent) {
            needsIndent = false
            printRaw(String(repeating: "  ", count: depth))
        }
        printRaw(message)
        if newLine {
            printRaw("\n")
            needsIndent = true
        }
    }

    public func println(_ message: String) {
        print(message, newLine: true)
    }
    
    public func print(_ items: [String], separator: String = ", ", newLine: Bool = false) {
        print(items.joined(separator: separator), newLine: newLine)
    }
    
    public func println(_ items: [String], separator: String = ", ") {
        print(items, separator: separator, newLine: true)
    }
    
    public func ln() {
        print("", newLine: true)
    }
    
    private func printRaw(_ message: String) {
        Swift.print(message, terminator: "")
    }
}
