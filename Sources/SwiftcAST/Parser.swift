import Foundation
import SwiftSyntax
import SwiftcBasic
import SwiftcType

public final class Parser {
    public let source: String
    
    private var currentContext: ASTContextNode?
    
    public init(source: String) {
        self.source = source
    }
    
    public convenience init(file: URL) throws {
        let source = try String(contentsOf: file)
        self.init(source: source)
    }
    
    private func scope(context: ASTContextNode?, _ f: () throws -> Void) rethrows {
        let old = currentContext
        currentContext = context
        try f()
        currentContext = old
    }
    
    public func parse() throws -> SourceFile {
        let syn = try SyntaxParser.parse(source: source)
        return try parse(syn)
    }
    
    private func parse(_ source: SourceFileSyntax) throws -> SourceFile {
        let sourceFile = SourceFile()
        try scope(context: sourceFile) {
            let statements = try parse(source.statements)
            for st in statements {
                sourceFile.addStatement(st)
            }
        }
        return sourceFile
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
                                        typeAnnotation: type)
                decls.append(decl)
            default:
                break
            }
        }
        
        return decls
    }
    
    private func parse(_ synFunc: FunctionDeclSyntax) throws -> FunctionDecl {
        let name = synFunc.identifier.text
        
        let sig = try parse(synFunc.signature)
        
        let funcDecl = FunctionDecl(parentContext: currentContext,
                                    name: name,
                                    parameterType: sig.0,
                                    resultType: sig.0)

        // body...
        
        return funcDecl
    }
    
    private func parse(_ synSig: FunctionSignatureSyntax) throws -> (Type, Type) {
        let synParamList = synSig.input.parameterList.map { $0 }
        guard synParamList.count == 1 else {
            throw MessageError("param num must be 1")
        }
        let synParam = synParamList[0]
        guard let synType = synParam.type else {
            throw MessageError("no param type")
        }
        
        let param: Type = try parse(type: synType)
        
        let result: Type = try synSig.output
            .map { try parse(type: $0.returnType) }
            ?? PrimitiveType.void
        
        return (param, result)
    }
    
    private func parse(expr: ExprSyntax) throws -> ASTNode {
        switch expr {
        case let expr as IdentifierExprSyntax:
            let name = expr.identifier.text
            return UnresolvedDeclRefExpr(name: name)
        case let expr as IntegerLiteralExprSyntax:
            _ = expr
            return IntegerLiteralExpr()
        case let expr as FunctionCallExprSyntax:
            let callee = try parse(expr: expr.calledExpression)
            let synArgList = expr.argumentList.map { $0 }
            guard synArgList.count == 1 else {
                throw MessageError("arg num must be 1")
            }
            let arg = try parse(expr: synArgList[0].expression)
            return CallExpr(callee: callee,
                            argument: arg)
        case let expr as ClosureExprSyntax:
            return try parse(expr)
        default:
            throw unsupportedSyntaxError(expr)
        }
    }
    
    private func parse(_ expr: ClosureExprSyntax) throws -> ClosureExpr {
        guard let synSig = expr.signature else {
            throw MessageError("no signature")
        }
        
        let param = try parse(synSig)
        
        let closure = ClosureExpr(parentContext: currentContext,
                                  parameter: param)
        
        try scope(context: closure) {
            closure.body = try parse(expr.statements)
        }
        
        guard closure.body.count == 1 else {
            throw MessageError("closure statements num must be 1")
        }
        
        return closure
    }
    
    private func parse(_ synSig: ClosureSignatureSyntax) throws -> VariableDecl {
        guard let synParamClause = synSig.input as? ParameterClauseSyntax else {
            throw MessageError("param num must be 1")
        }
        
        let synParamList = synParamClause.parameterList.map { $0 }
        guard synParamList.count == 1 else {
            throw MessageError("param num must be 1")
        }
        let synParam = synParamList[0]
        guard let name = synParam.firstName?.text else {
            throw MessageError("no param name")
        }
        
        let type: Type? = try synParam.type.map { try parse(type: $0) }
        
        return VariableDecl(name: name,
                            initializer: nil,
                            typeAnnotation: type)
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
