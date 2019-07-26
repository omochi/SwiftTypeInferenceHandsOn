import SwiftSyntax

public final class TypeInferer {
    private let entities: EntitySpace
    private var tvGen: TypeVariableGenerator = TypeVariableGenerator()
    private var syntaxTypeMap: SyntaxTypeMap = [:]
    private var unificator: Unificator = Unificator()
    
    public init(entities: EntitySpace) {
        self.entities = entities
    }
    
    public func infer(statement: Syntax) throws {
        try collect(syntax: statement)
        
        dump(syntax: statement)
    }
    
    private func mappedType(for syntax: Syntax) -> Type? {
        syntaxTypeMap[syntax.uniqueIdentifier]?.type
    }
    
    private func substitutedType(for syntax: Syntax) -> Type? {
        mappedType(for: syntax)
            .map { unificator.substitutions.apply(to: $0) }
    }
    
    // MARK:- collect

    public func collect(syntax: Syntax) throws {
        switch syntax {
        case let decl as VariableDeclSyntax:
            for binding in decl.bindings {
                try collect(binding)
            }
        case let call as FunctionCallExprSyntax:
            _ = try collect(call)
        default:
            break
        }
    }
    
    private func collect(_ binding: PatternBindingSyntax) throws {
        if let t1 = collect(pattern: binding.pattern),
            let initializer = binding.initializer,
            let t2 = try collect(expr: initializer.value)
        {
            try constrain(t1, t2)
        }
    }
    
    private func collect(pattern: PatternSyntax) -> Type? {
        switch pattern {
        case let pattern as IdentifierPatternSyntax:
            return createTypeVariable(for: pattern)
        default:
            return nil
        }
    }
    
    private func collect(expr: ExprSyntax) throws -> Type? {
        switch expr {
        case let expr as IntegerLiteralExprSyntax:
            let t = IntType()
            bindType(for: expr, type: t)
            return t
        case let expr as ClosureExprSyntax:
            guard let signature = expr.signature,
                let input = signature.input as? ParameterClauseSyntax else
            {
                throw MessageError("unsupported closure: \(expr)")
            }
            
            let argumentTypes: [Type] = input.parameterList.map { (parameter) in
                return createTypeVariable(for: parameter)
            }
            let resultType = createTypeVariable()
            
            let exprType = FunctionType(arguments: argumentTypes, result: resultType)
            bindType(for: expr, type: exprType)
            return exprType
        default:
            return nil
        }
    }
    
    private func collect(_ call: FunctionCallExprSyntax) throws -> Type? {
        let calleeName: String
        
        switch call.calledExpression {
        case let called as IdentifierExprSyntax:
            calleeName = called.identifier.text
        default:
            return nil
        }
        
        print("callee: \(calleeName)")
        
        let callArgumentTypes: [Type] = try call.argumentList.map { (argument) in
            guard let type = try collect(expr: argument.expression) else {
                throw MessageError("unsupported argument: \(argument)")
            }
            return type
        }
        
        print(callArgumentTypes)

        return nil
    }
    
    private func createTypeVariable(for syntax: Syntax) -> TypeVariable {
        let tv = tvGen.generate()
        bindType(for: syntax, type: tv)
        return tv
    }
    
    private func createTypeVariable() -> TypeVariable {
        return tvGen.generate()
    }
    
    private func bindType(for syntax: Syntax, type: Type) {
        syntaxTypeMap[syntax.uniqueIdentifier] = SyntaxTypePair(syntax: syntax, type: type)
    }
    
    private func constrain(_ t1: Type, _ t2: Type) throws {
        let constraint = Constraint(left: t1, right: t2)
        try unificator.unify(constraint: constraint)
    }
    
    // MARK:- dump
    
    private func dump(syntax: Syntax) {
        let printer = Dumper(owner: self)
        printer.print(syntax)
        
        Swift.print("Substitutions:")
        Swift.print(unificator.description)
    }
    
    private final class Dumper {
        private let owner: TypeInferer
        
        private var depth: Int = 0
        private var needsIndent: Bool = true
        
        public init(owner: TypeInferer) {
            self.owner = owner
        }
        
        public func print(_ syntax: Syntax) {
            switch syntax {
            case let syntax as VariableDeclSyntax:
                print("VarDecl")
                for binding in syntax.bindings {
                    nest {
                        print(binding)
                    }
                }
            case let syntax as PatternBindingSyntax:
                print("PatternBinding")
                
                if let pattern = syntax.pattern as? IdentifierPatternSyntax {
                    nest {
                        print("\(pattern.identifier.text) : \(typeString(for: pattern))")
                    }
                }
                if let initializer = syntax.initializer {
                    nest {
                        print(initializer)
                    }
                }
            case let syntax as FunctionCallExprSyntax:
                print("FunctionCall")
                if let name = syntax.calledExpression as? IdentifierExprSyntax {
                    nest {
                        print("callee: \(name.identifier.text)")
                    }
                }
                for (index, argument) in syntax.argumentList.enumerated() {
                    nest {
                        print("arg[\(index)]=", newLine: false)
                        print(argument.expression)
                    }
                }
            case let syntax as InitializerClauseSyntax:
                print(syntax.value)
            case let syntax as IntegerLiteralExprSyntax:
                print("\(syntax.digits.text) : \(typeString(for: syntax))")
            case let syntax as ClosureExprSyntax:
                print("Closure: \(typeString(for: syntax))")
            case let syntax as SequenceExprSyntax:
                print("SequenceExpr")
                for item in syntax.elements {
                    nest {
                        print(item)
                    }
                }
            case let syntax as BinaryOperatorExprSyntax:
                print(syntax.operatorToken.text)
            case let syntax as ExprSyntax:
                print("Expr")
                for item in syntax.children {
                    nest {
                        print(item)
                    }
                }
            case let syntax as TokenSyntax:
                print("Token: \(syntax.text)")
            default:
                print("??")
            }
        }
        
        private func typeString(for syntax: Syntax) -> String {
            return owner.mappedType(for: syntax)?.description ?? "??"
        }
        
        private func print(_ string: String, newLine: Bool = true) {
            if needsIndent {
                let indent = String(repeating: "  ", count: depth)
                Swift.print(indent, terminator: "")
                needsIndent = false
            }
            
            if newLine {
                Swift.print(string)
                needsIndent = true
            } else {
                Swift.print(string, terminator: "")
            }
        }
        
        private func nest(_ f: () -> Void) {
            depth += 1
            f()
            depth -= 1
        }
    }
}
