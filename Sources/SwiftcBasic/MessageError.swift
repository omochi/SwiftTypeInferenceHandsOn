import Foundation

public struct MessageError : LocalizedError, CustomStringConvertible {
    public var message: String
    
    public init(_ message: String) {
        self.message = message
    }
    
    public var description: String { message }
    
    public var errorDescription: String? { description }
}
