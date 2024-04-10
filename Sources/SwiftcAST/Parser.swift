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
            case let .decl(syn):
                if let syn = syn.as(VariableDeclSyntax.self) {
                    for decl in try parse(syn) {
                        stmts.append(decl)
                    }
                } else if let syn = syn.as(FunctionDeclSyntax.self) {
                    let decl = try parse(syn)
                    stmts.append(decl)
                }
            case let .expr(syn):
                let expr = try parse(expr: syn)
                stmts.append(expr)
            case .stmt:
                break
            }
        }
        
        return stmts
    }
    
    private func parse(_ varDecl: VariableDeclSyntax) throws -> [VariableDecl] {
        var decls: [VariableDecl] = []
        
        for binding in varDecl.bindings {
            guard let ident = binding.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }

            let name = ident.identifier.text
            let initializer: Expr? = try binding.initializer.map {
                try parse(expr: $0.value)
            } as? Expr
            let type: Type? = try binding.typeAnnotation.map {
                try parse(type: $0.type)
            }
            let decl = VariableDecl(source: source,
                                    sourceRange: SourceRange(syntax: Syntax(binding)),
                                    parentContext: currentContext,
                                    name: name,
                                    initializer: initializer,
                                    typeAnnotation: type)
            decls.append(decl)
        }
        
        return decls
    }
    
    private func parse(_ synFunc: FunctionDeclSyntax) throws -> FunctionDecl {
        let name = synFunc.name.text

        let sig = try parse(synFunc.signature)
        
        let funcDecl = FunctionDecl(source: source,
                                    sourceRange: SourceRange(syntax: Syntax(synFunc)),
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
        let sourceRange = SourceRange(syntax: Syntax(expr))
        if let expr = expr.as(DeclReferenceExprSyntax.self) {
            let name = expr.baseName.text
            return UnresolvedDeclRefExpr(source: source,
                                         sourceRange: sourceRange,
                                         name: name)
        } else if let expr = expr.as(IntegerLiteralExprSyntax.self) {
            _ = expr
            return IntegerLiteralExpr(source: source,
                                      sourceRange: sourceRange)
        } else if let expr = expr.as(FunctionCallExprSyntax.self) {
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
        } else if let expr = expr.as(ClosureExprSyntax.self) {
            return try parse(expr)
        } else {
            throw unsupportedSyntaxError(Syntax(expr))
        }
    }
    
    private func parse(_ expr: ClosureExprSyntax) throws -> ClosureExpr {
        guard let synSig = expr.signature else {
            throw MessageError("no signature")
        }
        
        let (param, ret) = try parse(synSig)
        
        let closure = ClosureExpr(source: source,
                                  sourceRange: SourceRange(syntax: Syntax(expr)),
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
        guard let synParamClause = synSig.parameterClause?.as(FunctionParameterClauseSyntax.self) else {
            throw MessageError("param num must be 1")
        }
        
        let synParamList = synParamClause.parameters.map { $0 }
        guard synParamList.count == 1 else {
            throw MessageError("param num must be 1")
        }
        let synParam = synParamList[0]
        let name = synParam.firstName.text
        
        let paramType: Type? = try parse(type: synParam.type)

        let result: Type? = try synSig.returnClause
            .map { try parse(type: $0.type) }

        let param = VariableDecl(source: source,
                                 sourceRange: SourceRange(syntax: Syntax(synParam)),
                                 parentContext: currentContext,
                                 name: name,
                                 initializer: nil,
                                 typeAnnotation: paramType)
        return (param, result)
    }
    
    private func parse(type: TypeSyntax) throws -> Type {
        if let type = type.as(IdentifierTypeSyntax.self) {
            let name = type.name.text
            return PrimitiveType(name: name)
        } else if let type = type.as(OptionalTypeSyntax.self) {
            let wrapped = try parse(type: type.wrappedType)
            return OptionalType(wrapped)
        } else if let type = type.as(FunctionTypeSyntax.self) {
            let synParamList = type.parameters.map { $0 }
            guard synParamList.count == 1 else {
                throw MessageError("param num must be 1")
            }
            let param = try parse(type: synParamList[0].type)
            let result = try parse(type: type.returnClause.type)
            return FunctionType(parameter: param, result: result)
        } else {
            throw unsupportedSyntaxError(Syntax(type))
        }
    }
    
    private func unsupportedSyntaxError(_ syntax: Syntax) -> MessageError {
        return MessageError("unsupported syntax: \(type(of: syntax)), \(syntax)")
    }
}
