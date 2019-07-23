import SwiftSyntax
import Foundation
import SwiftTypeInference

func main() throws {
    let path = Resources.file("a.swift")
    let source = try SyntaxParser.parse(path)
    
    for statement in source.statements {
//        dump(statement)
        let inferer = TypeInferer()
        let statement = inferer.infer(statement: statement.item)
        print(statement)
    }
 
}

try! main()
