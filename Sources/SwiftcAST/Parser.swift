import Foundation
import SwiftSyntax
import SwiftcBasic
import SwiftcType

public final class Parser {
    public let source: String
    
    public init(source: String) {
        self.source = source
    }
    
    public convenience init(file: URL) throws {
        let source = try String(contentsOf: file)
        self.init(source: source)
    }
    
    public func parse() throws -> SourceFile {
        let syn = try SyntaxParser.parse(source: source)
        return try parse(syn)
    }
    
    private func parse(_ source: SourceFileSyntax) throws -> SourceFile {
        var statements: [ASTNode] = []
        
        for syn in source.statements {
            switch syn.item {
            case let syn as VariableDeclSyntax:
                for decl in try parse(syn) {
                    statements.append(decl)
                }
            case let syn as FunctionDeclSyntax:
                let decl = try parse(syn)
                statements.append(decl)
            default:
                break
            }
        }
        
        return SourceFile(statements: statements)
    }
    
    private func parse(_ varDecl: VariableDeclSyntax) throws -> [VariableDecl] {
        var decls: [VariableDecl] = []
        
        for binding in varDecl.bindings {
            switch binding.pattern {
            case let ident as IdentifierPatternSyntax:
                let name = ident.identifier.text
                let initializer: ASTNode? = try binding.initializer.map {
                    try parse(expr: $0.value)
                }
                let type: Type? = try binding.typeAnnotation.map {
                    try parse(type: $0.type)
                }
                let decl = VariableDecl(name: name,
                                        initializer: initializer,
                                        typeAnnotation: type)
                decls.append(decl)
            default:
                break
            }
        }
        
        return decls
    }
    
    private func parse(_ funcDecl: FunctionDeclSyntax) throws -> FunctionDecl {
        let name = funcDecl.identifier.text
        let param: Type
        do {
            let synParamList = funcDecl.signature.input.parameterList.map { $0 }
            guard synParamList.count == 1 else {
                throw MessageError("param num must be 1")
            }
            let synParam = synParamList[0]
            guard let synType = synParam.type else {
                throw MessageError("no param type")
            }
            param = try parse(type: synType)
        }
        let result: Type
        do {
            if let output = funcDecl.signature.output {
                result = try parse(type: output.returnType)
            } else {
                result = PrimitiveType.void
            }
        }
        return FunctionDecl(name: name,
                            parameterType: param,
                            resultType: result)
    }
    
    private func parse(expr: ExprSyntax) throws -> ASTNode {
        switch expr {
        case let expr as IntegerLiteralExprSyntax:
            _ = expr
            return IntegerLiteralExpr()
        default:
            throw unsupportedSyntaxError(expr)
        }
    }
    
    private func parse(type: TypeSyntax) throws -> Type {
        switch type {
        case let type as SimpleTypeIdentifierSyntax:
            let name = type.name.text
            return PrimitiveType(name: name)
        case let type as FunctionTypeSyntax:
            let synParamList = type.arguments.map { $0 }
            guard synParamList.count == 1 else {
                throw MessageError("param num must be 1")
            }
            let param = try parse(type: synParamList[0].type)
            let result = try parse(type: type.returnType)
            return FunctionType(parameter: param, result: result)
        default:
            throw unsupportedSyntaxError(type)
        }
    }
    
    private func unsupportedSyntaxError(_ syntax: Syntax) -> MessageError {
        return MessageError("unsupported syntax: [\(syntax)]")
    }
}
