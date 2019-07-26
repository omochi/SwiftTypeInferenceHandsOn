import SwiftSyntax

public final class TypeInferer {
    private var tvGen: TypeVariableGenerator = TypeVariableGenerator()
    private var syntaxTypeMap: SyntaxTypeMap = [:]
    private var unificator: Unificator = Unificator()
    
    public init() {
    }
    
    public func infer(statement: Syntax) throws {
        var collector = SyntaxTypeCollector(syntax: statement,
                                            typeVariableGenerator: tvGen)
        collector.collect()
        
        try syntaxTypeMap.merge(collector.syntaxTypeMap,
                                uniquingKeysWith: { (a, b) in
                                    throw MessageError("syntax map conflict")
        })
        
        for constraint in collector.constraints {
            try unificator.unify(constraint: constraint)
        }
        
        print(syntax: statement)        
    }
    
    private func type(for syntax: Syntax) -> Type? {
        syntaxTypeMap[syntax.uniqueIdentifier]?.type
    }
    
    private func substitutedType(for syntax: Syntax) -> Type? {
        type(for: syntax).map { unificator.substitutions.apply(to: $0) }
    }
    
    private func annotate(binding: PatternBindingSyntax) -> PatternBindingSyntax {
        var binding = binding
        
        func proc() {
            guard var pattern = binding.pattern as? IdentifierPatternSyntax else { return }
            
            guard let tv = substitutedType(for: pattern) else { return }

            let trivia = pattern.identifier.trailingTrivia
                .appending(.blockComment("/* : \(tv) */"))
            let identifier = pattern.identifier
                .withTrailingTrivia(trivia)
            
            pattern = pattern.withIdentifier(identifier)
        
            binding = binding
                .withPattern(pattern)
        }
        
        proc()
        
        return binding
    }
    
    private func print(syntax: Syntax) {
        let printer = Printer(owner: self)
        printer.print(syntax)
        
        Swift.print("Substitutions:")
        Swift.print(unificator.description)
    }
    
    private final class Printer {
        private let owner: TypeInferer
        
        private var depth: Int = 0
        
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
            case let syntax as InitializerClauseSyntax:
                print(syntax.value)
            case let syntax as IntegerLiteralExprSyntax:
                print("\(syntax.digits.text) : \(typeString(for: syntax))")
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
            return owner.type(for: syntax)?.description ?? "??"
        }
        
        private func print(_ string: String) {
            let indent = String(repeating: "  ", count: depth)
            Swift.print(indent + string)
        }
        
        private func nest(_ f: () -> Void) {
            depth += 1
            f()
            depth -= 1
        }
    }
}
