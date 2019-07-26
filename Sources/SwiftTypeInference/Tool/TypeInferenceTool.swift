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
        collectEntities()
        print(entities)
        try inferTypes()
    }
    
    private func collectEntities() {
        for statement in source.statements {
            do {
                switch statement.item {
                case let decl as FunctionDeclSyntax:
                    let name = decl.identifier.description
                    let type = try functionDeclToType(decl)
                    entities.functions.append(Function(name: name,
                                                       type: type))
                default:
                    break
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func functionDeclToType(_ decl: FunctionDeclSyntax) throws -> FunctionType {
        let signature = decl.signature
        let arguments: [Type] = try signature.input.parameterList.map { (parameter) in
            guard let type = parameter.type else {
                throw MessageError("unsupported signature: \(signature)")
            }
            return try type.toType()
        }
        let result = try signature.output?.returnType.toType() ?? VoidType()
        return FunctionType(arguments: arguments,
                            result: result)
    }
    
    private func inferTypes() throws {
        for statement in source.statements {
            //        dump(statement)
            let inferer = TypeInferer(entities: entities)
            try inferer.infer(statement: statement.item)
            print(type(of: statement))
        }
    }
}
