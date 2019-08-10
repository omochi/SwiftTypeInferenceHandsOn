import SwiftSyntax

//public final class TypeInferer {
//    private let entities: EntitySpace
//    private var tvGen: TypeVariableGenerator = TypeVariableGenerator()
//    private var syntaxTypeMap: SyntaxTypeMap = [:]
//    public private(set) var unificator: Unificator = Unificator()
//    
//    public init(entities: EntitySpace) {
//        self.entities = entities
//    }
//    
//    public func infer(statement: Syntax) throws {
//        try collect(syntax: statement)
//        
//        dump(syntax: statement)
//    }
//    
//    public func mappedType(for syntax: Syntax) -> Type? {
//        syntaxTypeMap[syntax.uniqueIdentifier]?.type
//    }
//
//    public func collect(syntax: Syntax) throws {
//        switch syntax {
//        case let decl as VariableDeclSyntax:
//            for binding in decl.bindings {
//                try collect(binding)
//            }
//        case let call as FunctionCallExprSyntax:
//            _ = try collect(call)
//        default:
//            break
//        }
//    }
//    
//    private func collect(_ binding: PatternBindingSyntax) throws {
//        if let t1 = collect(pattern: binding.pattern),
//            let initializer = binding.initializer,
//            let t2 = try collect(expr: initializer.value)
//        {
//            try constrain(t1, t2)
//        }
//    }
//    
//    private func collect(pattern: PatternSyntax) -> Type? {
//        switch pattern {
//        case let pattern as IdentifierPatternSyntax:
//            return createTypeVariable(for: pattern)
//        default:
//            return nil
//        }
//    }
//    
//    private func collect(expr: ExprSyntax) throws -> Type? {
//        switch expr {
//        case let expr as IntegerLiteralExprSyntax:
//            let t = IntType()
//            bindType(for: expr, type: t)
//            return t
//        case let expr as ClosureExprSyntax:
//            guard let signature = expr.signature,
//                let input = signature.input as? ParameterClauseSyntax else
//            {
//                throw MessageError("unsupported closure: \(expr)")
//            }
//            
//            let argumentTypes: [Type] = input.parameterList.map { (parameter) in
//                return createTypeVariable(for: parameter)
//            }
//            let resultType = createTypeVariable()
//            
//            let exprType = FunctionType(arguments: argumentTypes, result: resultType)
//            bindType(for: expr, type: exprType)
//            return exprType
//        default:
//            return nil
//        }
//    }
//    
//    private func collect(_ call: FunctionCallExprSyntax) throws -> Type? {
//        let calleeName: String
//        
//        switch call.calledExpression {
//        case let called as IdentifierExprSyntax:
//            calleeName = called.identifier.text
//        default:
//            return nil
//        }
//        
//        guard let function = (entities.functions.first { $0.name == calleeName }) else {
//            throw MessageError("unknown function: \(calleeName)")
//        }
//        
//        let callArgumentTypes: [Type] = try call.argumentList.map { (argument) in
//            guard let type = try collect(expr: argument.expression) else {
//                throw MessageError("unsupported argument: \(argument)")
//            }
//            return type
//        }
//        
//        for (defArg, callArg) in zip(function.type.arguments, callArgumentTypes) {
//            try constrain(defArg, callArg)
//        }
//        
//        let callType = createTypeVariable(for: call)
//
//        try constrain(function.type.result, callType)
//
//        return callType
//    }
//    
//    private func createTypeVariable(for syntax: Syntax) -> TypeVariable {
//        let tv = tvGen.generate()
//        bindType(for: syntax, type: tv)
//        return tv
//    }
//    
//    private func createTypeVariable() -> TypeVariable {
//        return tvGen.generate()
//    }
//    
//    private func bindType(for syntax: Syntax, type: Type) {
//        syntaxTypeMap[syntax.uniqueIdentifier] = SyntaxTypePair(syntax: syntax, type: type)
//    }
//    
//    private func constrain(_ t1: Type, _ t2: Type) throws {
//        let constraint = Constraint(left: t1, right: t2)
//        try unificator.unify(constraint: constraint)
//    }
//}
