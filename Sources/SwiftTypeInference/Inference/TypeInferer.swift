import SwiftSyntax

public final class TypeInferer {
    private var tvGen: TypeVariableGenerator = TypeVariableGenerator()
    private var syntaxTypeMap: [SyntaxIdentifier: (syntax: Syntax, type: Type)] = [:]
    private var unificator: Unificator = Unificator()
    
    public init() {
    }
    
    public func infer(statement: Syntax) -> Syntax {
        var visitor = CollectVisitor(owner: self)
        statement.walk(&visitor)
        
        print(syntax: statement)
        
        let writer = AnnotateRewriter(owner: self)
        return writer.visit(statement)
    }
    
    private func collectConstraints(expression: Syntax) {
        var visitor = CollectVisitor(owner: self)
        expression.walk(&visitor)
    }

    private func bindType(for syntax: Syntax, type: Type) {
        syntaxTypeMap[syntax.uniqueIdentifier] = (syntax, type)
    }
    
    private func type(for syntax: Syntax) -> Type? {
        syntaxTypeMap[syntax.uniqueIdentifier]?.type
    }
    
    private func substitutedType(for syntax: Syntax) -> Type? {
        type(for: syntax).map { unificator.substitutions.apply(to: $0) }
    }
    
    private func constrain(_ left: Type, _ right: Type) throws {
        try unificator.unify(constraint: Constraint(left: left, right: right))
    }
    
    private func collect(binding: PatternBindingSyntax) throws {
        func collectPattern() -> Type? {
            switch binding.pattern {
            case let pattern as IdentifierPatternSyntax:
                let tv = tvGen.generate()
                bindType(for: pattern, type: tv)
                return tv
            default:
                return nil
            }
        }
        
        let t1 = collectPattern()
        
        if let initializer = binding.initializer {
            if let t2 = try collect(expr: initializer.value) {
                if let t1 = t1 {
                    try constrain(t1, t2)
                }
            }
        }
    }
    
    private func collect(expr: ExprSyntax) throws -> Type? {
        switch expr {
        case let expr as IntegerLiteralExprSyntax:
            let tv = tvGen.generate()
            bindType(for: expr, type: tv)
            try constrain(tv, IntType())
            return tv
        default:
            return nil
        }
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
    
    private final class CollectVisitor : SyntaxVisitorBase {
        private let owner : TypeInferer
        
        public init(owner: TypeInferer) {
            self.owner = owner
        }
        
        public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
            for binding in node.bindings {
                // TODO
                try! owner.collect(binding: binding)
            }
            
            return .skipChildren
        }
    }
    
    private final class AnnotateRewriter : SyntaxRewriter {
        private let owner: TypeInferer
        
        public init(owner: TypeInferer) {
            self.owner = owner
        }
        
        public override func visit(_ node: PatternBindingSyntax) -> Syntax {
            return owner.annotate(binding: node)
        }
    }
}
