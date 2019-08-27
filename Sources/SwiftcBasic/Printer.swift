import Foundation

public final class Printer {
    public var depth: Int
    public var isAtLineHead: Bool
    public var isEnabled: Bool
    public var doesCapture: Bool
    public var capturedOutput: String
    
    public init(depth: Int = 0)
    {
        self.isEnabled = true
        self.doesCapture = false
        self.capturedOutput = ""
        self.depth = depth
        self.isAtLineHead = true
    }
    
    public func push() {
        depth += 1
    }
    
    public func pop() {
        depth -= 1
    }
    
    public func nest<R>(_ f: () throws -> R) rethrows -> R {
        push()
        defer { pop() }
        return try f()
    }
    
    public func capture(_ f: () throws -> Void) rethrows -> String {
        doesCapture = true
        try f()
        return capturedOutput
    }
    
    public func print(_ message: String, newLine: Bool = false) {
        if (isAtLineHead) {
            printRaw(String(repeating: "  ", count: depth))
            isAtLineHead = false
        }
        printRaw(message)
        if newLine {
            printRaw("\n")
            isAtLineHead = true
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
    
    public func goToLineHead() {
        if !isAtLineHead {
            ln()
        }
    }
    
    private func printRaw(_ message: String) {
        guard isEnabled else {
            return
        }
        
        if doesCapture {
            capturedOutput.append(message)
        } else {
            Swift.print(message, terminator: "")
        }
    }
}
