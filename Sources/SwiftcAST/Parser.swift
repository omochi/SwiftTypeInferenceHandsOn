import Foundation
import SwiftSyntax
import SwiftcBasic
import SwiftcType

public final class Parser {
    public let sourceString: String
    public let fileName: String?
    
    public var source: SourceFile!
    private var currentContext: DeclContext!
    
    public init(source: String, fileName: String? = nil) {
        self.sourceString = source
        self.fileName = fileName
    }
    
    public convenience init(file: URL) throws {
        let source = try String(contentsOf: file)
        self.init(source: source,
                  fileName: file.lastPathComponent)
    }
    
    private func scope(context: DeclContext, _ f: () throws -> Void) rethrows {
        let old = currentContext
        currentContext = context
        defer {
            currentContext = old
        }
        try f()
    }
    
    public func parse() throws -> SourceFile {
        let syn = try SyntaxParser.parse(source: sourceString)

        var data = sourceString.data(using: .utf8)!
        let size = data.count
        data.append(0)
        
        let sourceRange = SourceRange(begin: SourcePosition(rawValue: 0),
                                      end: SourcePosition(rawValue: size))
        
        let lineMap = SourceLineMap(nullTerminatedData: data)
        
        let source = SourceFile(sourceRange: sourceRange,
                                    fileName: fileName,
                                    sourceLineMap: lineMap)
        self.source = source
        try scope(context: source) {
            let statements = try parse(syn.statements)
            for st in statements {
                source.addStatement(st)
            }
        }
        return source
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
                let initializer: Expr? = try binding.initializer.map {
                    try parse(expr: $0.value)
                } as? Expr
                let type: Type? = try binding.typeAnnotation.map {
                    try parse(type: $0.type)
                }
                let decl = VariableDecl(source: source,
                                        sourceRange: SourceRange(syntax: binding),
                                        parentContext: currentContext,
                                        name: name,
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
        let name = synFunc.name.text

        let sig = try parse(synFunc.signature)
        
        let funcDecl = FunctionDecl(source: source,
                                    sourceRange: SourceRange(syntax: synFunc),
                                    parentContext: currentContext,
                                    name: name,
                                    parameterType: sig.0,
                                    resultType: sig.1)

        // body...
        
        return funcDecl
    }
    
    private func parse(_ synSig: FunctionSignatureSyntax) throws -> (Type, Type) {
        let synParamList = synSig.parameterClause.parameters.map { $0 }
        guard synParamList.count == 1 else {
            throw MessageError("param num must be 1")
        }
        let synParam = synParamList[0]
        let synType = synParam.type
        
        let param: Type = try parse(type: synType)
        
        let result: Type = try synSig.returnClause
            .map { try parse(type: $0.type) }
            ?? PrimitiveType.void
        
        return (param, result)
    }
    
    private func parse(expr: ExprSyntax) throws -> ASTNode {
        let sourceRange = SourceRange(syntax: expr)
        switch expr {
        case let expr as IdentifierExprSyntax:
            let name = expr.baseName.text
            return UnresolvedDeclRefExpr(source: source,
                                         sourceRange: sourceRange,
                                         name: name)
        case let expr as IntegerLiteralExprSyntax:
            _ = expr
            return IntegerLiteralExpr(source: source,
                                      sourceRange: sourceRange)
        case let expr as FunctionCallExprSyntax:
            let callee = try parse(expr: expr.calledExpression) as! Expr
            let synArgList = expr.arguments.map { $0 }
            guard synArgList.count == 1 else {
                throw MessageError("arg num must be 1")
            }
            let arg = try parse(expr: synArgList[0].expression) as! Expr
            return CallExpr(source: source,
                            sourceRange: sourceRange,
                            callee: callee,
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
        
        let (param, ret) = try parse(synSig)
        
        let closure = ClosureExpr(source: source,
                                  sourceRange: SourceRange(syntax: expr),
                                  parentContext: currentContext,
                                  parameter: param,
                                  returnType: ret)
        
        try scope(context: closure) {
            closure.body = try parse(expr.statements)
        }
        
        guard closure.body.count == 1 else {
            throw MessageError("closure statements num must be 1")
        }
        
        return closure
    }
    
    private func parse(_ synSig: ClosureSignatureSyntax) throws -> (VariableDecl, Type?) {
        guard let synParamClause = synSig.input as? ParameterClauseSyntax else {
            throw MessageError("param num must be 1")
        }
        
        let synParamList = synParamClause.parameters.map { $0 }
        guard synParamList.count == 1 else {
            throw MessageError("param num must be 1")
        }
        let synParam = synParamList[0]
        let name = synParam.firstName.text
        
        let paramType: Type? = try synParam.type.map { try parse(type: $0) }
        
        let result: Type? = try synSig.returnClause
            .map { try parse(type: $0.type) }

        let param = VariableDecl(source: source,
                                 sourceRange: SourceRange(syntax: synParam),
                                 parentContext: currentContext,
                                 name: name,
                                 initializer: nil,
                                 typeAnnotation: paramType)
        return (param, result)
    }
    
    private func parse(type: TypeSyntax) throws -> Type {
        switch type {
        case let type as SimpleTypeIdentifierSyntax:
            let name = type.name.text
            return PrimitiveType(name: name)
        case let type as OptionalTypeSyntax:
            let wrapped = try parse(type: type.wrappedType)
            return OptionalType(wrapped)
        case let type as FunctionTypeSyntax:
            let synParamList = type.parameters.map { $0 }
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
