import Foundation
import SwiftSyntax

public final class TypeInferenceTool {
    private let source: SourceFileSyntax
    private let entities: EntitySpace
    
    public convenience init(path: URL) throws {
        let source = try SyntaxParser.parse(path)
        self.init(source: source)
    }
    
    private init(source: SourceFileSyntax) {
        self.source = source
        self.entities = EntitySpace()
    }
    
    public func run() throws {
        collectTypes()
        inferTypes()
    }
    
    private func collectTypes() {
        for statement in source.statements {
            switch statement.item {
                
            }
        }
    }
    
    private func inferTypes() {
        for statement in source.statements {
            //        dump(statement)
            let inferer = TypeInferer()
            let statement = inferer.infer(statement: statement.item)
            print(statement)
        }
    }
}
