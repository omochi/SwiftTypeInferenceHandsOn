import Foundation
import SwiftcAST
import SwiftcSema

public final class Compiler {
    private var source: SourceFile?
    
    public init() {
    }
    
    public func addSource(file: URL) throws {
        let parser = try Parser(file: file)
        self.source = try parser.parse()
    }
    
    public func typeCheck() {
        let checker = TypeChecker()
    }
}
