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
        let stmts = try parse(source.statements)

        return SourceFile(statements: stmts,
                          sourceRange: source.position..<source.endPosition)
    }
    
    private func parse(_ synStmts: CodeBlockItemListSyntax) throws -> [ASTNode] {
        var stmts: [ASTNode] = []
        
        for syn in synStmts {
            switch syn.item {
            case let syn as VariableDeclSyntax:
                for decl in try parse(syn) {
                    stmts.append(decl)
                }
            case let syn as FunctionDeclSyntax:
                let decl = try parse(syn)
                stmts.append(decl)
            case let syn as ExprSyntax:
                let expr = try parse(expr: syn)
                stmts.append(expr)
            default:
                break
            }
        }
        
        return stmts
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
                                        typeAnnotation: type,
                                        sourceRange: ident.position..<ident.endPosition)
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
                            resultType: result,
                            sourceRange: funcDecl.position..<funcDecl.endPosition)
    }
    
    private func parse(expr: ExprSyntax) throws -> ASTNode {
        switch expr {
        case let expr as IdentifierExprSyntax:
            let name = expr.identifier.text
            return UnresolvedDeclRefExpr(name: name,
                                         sourceRange: expr.position..<expr.endPosition)
        case let expr as IntegerLiteralExprSyntax:
            _ = expr
            return IntegerLiteralExpr(sourceRange: expr.position..<expr.endPosition)
        case let expr as FunctionCallExprSyntax:
            let callee = try parse(expr: expr.calledExpression)
            let synArgList = expr.argumentList.map { $0 }
            guard synArgList.count == 1 else {
                throw MessageError("arg num must be 1")
            }
            let arg = try parse(expr: synArgList[0].expression)
            return CallExpr(callee: callee,
                            argument: arg,
                            sourceRange: expr.position..<expr.endPosition)
        case let expr as ClosureExprSyntax:
            return try parse(expr)
        default:
            throw unsupportedSyntaxError(expr)
        }
    }
    
    private func parse(_ expr: ClosureExprSyntax) throws -> ClosureExpr {
        guard let sig = expr.signature,
            let synParamClause = sig.input as? ParameterClauseSyntax,
            let synParamList = .some(synParamClause.parameterList.map { $0 }),
            synParamList.count == 1 else {
                throw MessageError("param num must be 1")
        }
        let synParam = synParamList[0]
        guard let paramName = synParam.firstName?.text else {
            throw MessageError("param needs name")
        }
        let paramDecl = VariableDecl(name: paramName,
                                     initializer: nil,
                                     typeAnnotation: try synParam.type.map { try parse(type: $0) },
                                     sourceRange: expr.position..<expr.endPosition)
        let stmts = try parse(expr.statements)
        guard stmts.count == 1 else {
            throw MessageError("closure statements num must be 1")
        }
        let body = stmts[0]
        return ClosureExpr(parameter: paramDecl,
                           expression: body,
                           sourceRange: expr.position..<expr.endPosition)
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
        return MessageError("unsupported syntax: \(type(of: syntax)), \(syntax)")
    }
}
